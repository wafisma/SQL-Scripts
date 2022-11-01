/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
       inv.[gkey]
      ,[id]
      ,inv.[visit_state]    
      ,[category]
      ,[freight_kind]
      ,invf.[time_out]
  FROM [sparcsn4].[dbo].[inv_ar_unit] inv
  INNER JOIN inv_ar_unit_fcy_visit invf ON invf.unit_gkey=inv.original_gkey
  WHERE [category]='IMPRT' AND inv.[visit_state]='3DEPARTED' AND invf.[time_out] BETWEEN '2021-01-01'  AND '2021-12-31' 
  AND ((DATEPART(dw, invf.[time_out]) + @@DATEFIRST) % 7) IN (0,1)


SELECT 
       inv.[gkey]
      ,[id]
      ,inv.[visit_state]    
      ,[category]
      ,[freight_kind]
      ,invf.[time_out]
  FROM [sparcsn4].[dbo].[inv_unit] inv
  INNER JOIN inv_unit_fcy_visit invf ON invf.unit_gkey=inv.gkey
  WHERE [category]='IMPRT' AND inv.[visit_state]='3DEPARTED' AND invf.[time_out] BETWEEN '2021-01-01'  AND '2021-12-31' 
  AND ((DATEPART(dw, invf.[time_out]) + @@DATEFIRST) % 7) IN (0,1)
