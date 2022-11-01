/****** Script for SelectTopNRows command from SSMS  ******/
with cte1 as (
SELECT distinct inv.gkey AS 'GKEY'
      ,inv.[id] AS 'CONTAINER'   
	  ,vvd.vvd_gkey AS 'VVD_GKEY'
	  ,inv.[category] AS 'CATEGORY'
	  ,bol.nbr AS 'BL NUMBER'
	  ,tva.created AS 'APPOINTMENT DATE AND TIME'
	  ,tt.tran_flex_date01 AS 'TERMINAL TIME OUT'
      ,iufv.[transit_state] AS 'TRANSIT STATE'
      ,inv.[flex_string01] AS 'GROUP CODE'
	  ,inv.[flex_string07] AS 'BOE NUMBER'
      ,inv.[flex_string08] AS 'COLOR CODE'
	  ,iufv.[time_in] AS 'DISCHARGE DATE AND TIME'
	  ,iufv.[time_out] AS 'PORT OUT GATE'
	  ,iufv.[time_load] AS 'TIME LOAD'
	  ,vvd.[start_work] AS 'START_TIME_CARGO_UNLOADING'
	  ,vvd.[end_work] AS 'END_TIME_CARGO_UNLOADING'
	  ,min(srf.placed_time) OVER(PARTITION BY inv.[id]) AS 'CUSTOMS_RELEASE_RECIEVED_TIME'
FROM [sparcsn4].[dbo].[inv_unit] inv
INNER JOIN [inv_unit_fcy_visit] iufv ON iufv.unit_gkey=inv.gkey
INNER JOIN [road_truck_transactions] tt ON tt.unit_gkey=inv.gkey
INNER JOIN [crg_bl_goods]cbg ON cbg.gds_gkey = inv.goods
INNER JOIN [crg_bills_of_lading] bol ON cbg.bl_gkey = bol.gkey 
INNER JOIN [inv_move_event] me ON iufv.gkey=me.ufv_gkey
INNER JOIN argo_carrier_visit acv on me.carrier_gkey=acv.gkey
INNER JOIN vsl_vessel_visit_details vvd on  acv.cvcvd_gkey=vvd.vvd_gkey
INNER JOIN [road_gate_appointment] rga on rga.unit_gkey=iufv.unit_gkey
INNER JOIN road_truck_visit_appt tva on tva.gkey=rga.truck_visit_appt_gkey
INNER JOIN [srv_event] srve ON srve.applied_to_gkey=inv.gkey
INNER JOIN [srv_event_types] ety ON  ety.gkey=srve.event_type_gkey
INNER JOIN [srv_flags] srf on inv.gkey=srf.applied_to_gkey
WHERE inv.[category]='IMPRT'
AND inv.[flex_string01]='MPS'
AND inv.[flex_string08] IN ('RED','YELLOW')
AND iufv.[transit_state]='S70_DEPARTED'
AND tt.status in ('COMPLETE','OK') AND inv.id IN ( 'MSDU1455909','TCNU1020748','INKU6533863','INBU3652280','CAXU6352430','TRHU7248662') 
AND srf.applied_to_class = 'UNIT'  AND srf.note LIKE ('%CUSTOMS PERMISSION%' )  
--AND iufv.[time_in]>='2022-10-25' AND iufv.[time_in]<'2022-10-27' AND time_out IS NOT NULL
) 
,cte2 as (
SELECT distinct inv.gkey AS 'GKEY'
	  ,min(srf.placed_time) OVER(PARTITION BY inv.[id]) AS 'ELECTRONIC_DELIVERY_ORDER_TIME'
FROM [sparcsn4].[dbo].[inv_unit] inv
INNER JOIN [srv_flags] srf on inv.gkey=srf.applied_to_gkey
AND srf.applied_to_class = 'UNIT'  AND srf.note LIKE ('%IMPORT LINE PERMISSION%' )
)
,cte3 as (
SELECT  inv.gkey AS 'GKEY'
      ,inv.[id] AS 'CONTAINER'   
	  ,min(srve.placed_time) OVER(PARTITION BY inv.[id]) AS 'VERDICT TIME'
FROM [sparcsn4].[dbo].[inv_unit] inv
INNER JOIN [srv_event] srve ON srve.applied_to_gkey=inv.gkey
INNER JOIN [srv_event_types] ety ON  ety.gkey=srve.event_type_gkey
AND ety.[id] in ('SCAN_NORMAL_VERDICT','SCAN_ABNORMAL_VERDICT') --AND inv.gkey in (9795568,9798683,9798861,9799057,9799207,9803561)
)
,cte4 as (
SELECT inv.gkey AS 'GKEY'
      ,inv.[id] AS 'CONTAINER'   
	  ,min(srve.placed_time) OVER(PARTITION BY inv.[id]) AS 'SCAN TIME'
FROM [sparcsn4].[dbo].[inv_unit] inv
INNER JOIN [srv_event] srve ON srve.applied_to_gkey=inv.gkey
INNER JOIN [srv_event_types] ety ON  ety.gkey=srve.event_type_gkey
AND ety.[id] in ('SCAN_IMAGE_PROCESSED') --AND inv.gkey in (9795568,9798683,9798861,9799057,9799207,9803561)
)
SELECT cte1.GKEY,cte1.VVD_GKEY,cte1.CONTAINER,cte1.CATEGORY,cte1.[BL NUMBER],cte1.[APPOINTMENT DATE AND TIME],cte1.[TERMINAL TIME OUT],cte1.[TRANSIT STATE],cte1.[GROUP CODE],
cte1.[BOE NUMBER],cte1.[COLOR CODE],cte1.[DISCHARGE DATE AND TIME],cte1.[PORT OUT GATE],cte1.[TIME LOAD],cte1.START_TIME_CARGO_UNLOADING,cte1.END_TIME_CARGO_UNLOADING
,cte1.CUSTOMS_RELEASE_RECIEVED_TIME,cte2.ELECTRONIC_DELIVERY_ORDER_TIME,cte3.[VERDICT TIME],cte4.[SCAN TIME]
FROM cte1 
INNER JOIN cte2 ON cte2.GKEY=cte1.GKEY
INNER JOIN cte3 ON cte3.GKEY=cte1.GKEY
INNER JOIN cte4 ON cte4.GKEY=cte1.GKEY
--