   ;with cteuser as(
SELECT  [LOG_ID],[VISIT_ID],[EVENT],[LOG_LEVEL],[SOURCE],[STATEMENT],[NAME],[DESCRIPTION],[LOG_TIMESTAMP] AS ACTIVITY_TIMESTAMP
FROM [MPSPROD].[dbo].[VISITLOG] a 
JOIN [MPSPROD].[dbo].[ACS_USER] b ON a.[STATEMENT] LIKE '%'+ b.NAME +'%' where  a.[LOG_TIMESTAMP]>dateadd(month,-3, GETDATE())
)
,ctedone as (
select [LOG_ID],b.[VISIT_ID],b.[EVENT],b.[STATEMENT],b.[LOG_TIMESTAMP] as STAGE_DONE_OK,b.[SOURCE]
 from [VISITLOG] b
 where b.[EVENT]= 'STAGE_DONE_OK'  and  b.[LOG_TIMESTAMP]>dateadd(month,-3, GETDATE()) 
)
SELECT cteuser.[LOG_ID],cteuser.[VISIT_ID],[LOG_LEVEL],cteuser.[SOURCE],CONCAT(ctedone.[STATEMENT] , '__', cteuser.[STATEMENT] ) AS STATEMENT_VISIT_EVENT
,cteuser.[NAME],cteuser.[DESCRIPTION],ACTIVITY_TIMESTAMP,ctedone.STAGE_DONE_OK,(DATEDIFF(second, cteuser.ACTIVITY_TIMESTAMP,ctedone.STAGE_DONE_OK) )/60.0 AS DURATION 
from cteuser join  ctedone on ctedone.[SOURCE]=cteuser.[SOURCE] where cteuser.VISIT_ID=ctedone.VISIT_ID