Create or Replace View if_db1.if_schema1.FAILEDPN AS
SELECT failedpn.metric_date,
       failedpn.metric_hour,
       failedpn.game_id,
       failedpn.game_id_str,
       failedpn.user_id,
       failedpn.event_ts,
       failedpn.bundle_id,
       failedpn.mkt,
       failedpn.mkt_str,
       failedpn.device_token
FROM bi_pipeline.failedpn