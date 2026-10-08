-- aplicado no banco do TEAM's (lhqjfdexfexpmnoqhbyv) em 07/10/2026 (texto lido do banco)
CREATE OR REPLACE FUNCTION public.teams_push_nao_lidas(p_usuario uuid)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select count(*)::int
    from chat_canal c
    left join chat_canal_membro me on me.canal_id = c.id and me.usuario_id = p_usuario
    join chat_mensagem u on u.canal_id = c.id
   where not c.arquivado
     and (c.tipo in ('setor','central') or me.usuario_id is not null)
     and not coalesce(me.silenciado, false)
     and u.excluida_em is null
     and u.autor_id <> p_usuario
     and u.tipo <> 'sistema'
     and u.criada_em > coalesce(me.ultima_leitura_em, me.entrou_em - interval '1 second', now() - interval '7 days');
$function$;
revoke all on function public.teams_push_nao_lidas(uuid) from public, anon, authenticated;
grant execute on function public.teams_push_nao_lidas(uuid) to service_role;

CREATE OR REPLACE FUNCTION public.teams_push_disparar()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_temp'
AS $function$
declare v_gatilho text; v_evento text;
begin
  if tg_table_name = 'chat_mensagem' then
    if new.tipo = 'sistema' then return new; end if;
    v_evento := 'mensagem';
  elsif tg_table_name = 'chat_chamada' then
    if tg_op = 'INSERT' then
      v_evento := 'chamada';
    elsif new.encerrada_em is not null and old.encerrada_em is null and new.atendida_em is null then
      v_evento := 'chamada_perdida';
    else
      return new;
    end if;
  elsif tg_table_name = 'chat_aviso' then
    v_evento := 'aviso';
  elsif tg_table_name = 'chat_pedido' then
    v_evento := 'pedido';
  elsif tg_table_name = 'chat_reuniao_participante' then
    v_evento := 'reuniao';
  else
    return new;
  end if;
  select decrypted_secret into v_gatilho from vault.decrypted_secrets where name = 'teams_push_gatilho';
  perform net.http_post(
    url := 'https://lhqjfdexfexpmnoqhbyv.supabase.co/functions/v1/teams-push',
    headers := jsonb_build_object('Content-Type','application/json','x-gatilho', v_gatilho),
    body := case when tg_table_name = 'chat_reuniao_participante'
                 then jsonb_build_object('evento', v_evento, 'id', new.reuniao_id, 'usuario_id', new.usuario_id)
                 else jsonb_build_object('evento', v_evento, 'id', new.id) end
  );
  return new;
exception when others then
  return new;
end $function$;
revoke all on function public.teams_push_disparar() from public, anon, authenticated;

CREATE TRIGGER teams_push_mensagem AFTER INSERT ON public.chat_mensagem FOR EACH ROW EXECUTE FUNCTION teams_push_disparar();
CREATE TRIGGER teams_push_chamada AFTER INSERT OR UPDATE OF encerrada_em ON public.chat_chamada FOR EACH ROW EXECUTE FUNCTION teams_push_disparar();
CREATE TRIGGER teams_push_aviso AFTER INSERT ON public.chat_aviso FOR EACH ROW EXECUTE FUNCTION teams_push_disparar();
CREATE TRIGGER teams_push_pedido AFTER INSERT ON public.chat_pedido FOR EACH ROW EXECUTE FUNCTION teams_push_disparar();
CREATE TRIGGER teams_push_reuniao AFTER INSERT ON public.chat_reuniao_participante FOR EACH ROW EXECUTE FUNCTION teams_push_disparar();
