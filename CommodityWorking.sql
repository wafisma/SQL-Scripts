   
with CTE as(   
   SELECT 
[inv_unit_fcy_visit].time_in AS ArrivalDate
, [crg_bills_of_lading].[nbr] BLNumber
    ,  [inv_unit].[id] Container
	,[inv_unit].flex_string01 as Groupcodes
                , [ref_equip_type].nominal_length CtrSize
      ,[freight_kind] AS Freight_Kind
                           ,OriginPort = 
                                  CASE 
                                         WHEN [crg_bills_of_lading].origin IS NULL THEN [ref_routing_point].id     
                                         ELSE [crg_bills_of_lading].origin
                                  END
    , Country = CASE WHEN OrgCountry.[cntry_name] IS NULL THEN POLCountry.[cntry_name] ELSE OrgCountry.[cntry_name] END
      , Destination = 
                              CASE
                                                                     WHEN [inv_unit].flex_string01 in ('GPHY','TSY','RFY') THEN 'Transit'
                                                                                ELSE 'Ghana'
                                                                  END  
                  , [crg_bl_item].notes
                  , [ref_bizunit_scoped].name AgentName
  FROM [sparcsn4].[dbo].[inv_unit]
  JOIN [sparcsn4].[dbo].[inv_unit_fcy_visit] ON [sparcsn4].[dbo].[inv_unit].gkey=[sparcsn4].[dbo].[inv_unit_fcy_visit].unit_gkey
  JOIN [sparcsn4].[dbo].[crg_bl_goods] ON [crg_bl_goods].gds_gkey = [inv_unit].goods
  JOIN [sparcsn4].[dbo].[crg_bills_of_lading] ON [crg_bl_goods].bl_gkey = [crg_bills_of_lading].gkey
  JOIN [sparcsn4].[dbo].[crg_bl_item] ON [crg_bl_item].bl_gkey = [crg_bills_of_lading].gkey
  JOIN [sparcsn4].[dbo].[ref_routing_point] ON [ref_routing_point].gkey = [inv_unit].pol_gkey
  JOIN [sparcsn4].[dbo].[ref_equipment] ON [sparcsn4].[dbo].[ref_equipment].gkey=[sparcsn4].[dbo].[inv_unit].eq_gkey
  JOIN [sparcsn4].[dbo].[ref_equip_type] ON [sparcsn4].[dbo].[ref_equip_type].gkey=[sparcsn4].[dbo].[ref_equipment].eqtyp_gkey
  LEFT OUTER JOIN [sparcsn4].[dbo].[ref_bizunit_scoped] ON [inv_unit].agent1=[ref_bizunit_scoped].gkey
  LEFT OUTER JOIN [sparcsn4].[dbo].[ref_country] OrgCountry ON OrgCountry.[cntry_code] = SUBSTRING([crg_bills_of_lading].origin, 1,2)
   LEFT OUTER JOIN [sparcsn4].[dbo].[ref_country] POLCountry ON POLCountry.[cntry_code] = SUBSTRING([ref_routing_point].id, 1,2)
  where [inv_unit].category = 'IMPRT'
  and [inv_unit].freight_kind in ('FCL', 'LCL')
  )
--Select ArrivalDate,BLNumber,Container,OriginPort,Country, Notes,Groupcodes,Freight_Kind,Destination from CTE

, CTE1 as (
SELECT ref_type,id1,id2, Members.Member.value('.','VARCHAR(8000)') CommoditySplit
FROM
(--Convert delimited string to XML
 SELECT  ref_type,id1,id2, CAST('<Players><Player>'
        + REPLACE(value1, ',' , '</Player><Player>') 
    + '</Player></Players>' AS XML) AS tempPlayer 
 FROM argo_general_reference ) AS tempPlayer
 CROSS APPLY tempPlayer.nodes('/Players/Player') Members(Member) where ref_type='COMMODITIES'
 )
 select ArrivalDate,BLNumber,Container,OriginPort,Country, Notes,Groupcodes,Freight_Kind,Destination,
 id1 as Categories,id2 as SubCategories,CommoditySplit as Keywords from CTE1 join CTE on CTE.notes LIKE '%'+ CTE1.CommoditySplit +'%' 