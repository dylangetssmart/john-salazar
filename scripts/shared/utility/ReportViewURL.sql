update sma_mst_sareports
set
    ReportViewerURL = replace(
                                replace(ReportViewerURL,'http://sql64', ''),
                                '/ReportServer/Pages/ReportViewer.aspx?'
                                ,'https://rpt.smartadvocate.com/ReportServer/Pages/ReportViewer.aspx?/SAglpattorneysLaw'
                            )
    ,ReportSubscriptionURL = replace(
                                        replace(
                                                replace(ReportSubscriptionURL,
                                                    'http://sql64/Reports/Pages/SubscriptionProperties.aspx?CreateNew=True&IsDataDriven=False&ItemPath=','https://rpt.smartadvocate.com/Reports/manage/catalogitem/addsubscription/SAglpattorneysLaw'
                                                    ),'/Reports/Pages/SubscriptionProperties.aspx?CreateNew=True&IsDataDriven=False&ItemPath=','https://rpt.smartadvocate.com/Reports/manage/catalogitem/addsubscription/SAglpattorneysLaw'
                                                ),'&RedirectUrl=CloseWindow.html','')
where ReportViewerURL not like '%rpt.%'
go

Insert into Account_Pages
select 'Medical Provider Report','/SAReports.aspx?reportid=MedicalProviderReport/MedicalProviderReport','Medical Reports',null,null
where not exists (select * From Account_Pages where  page_url like '%/SAReports.aspx?reportid=MedicalProviderReport/MedicalProviderReport%')
go
insert into Account_PagesInRoles
select distinct role_id,page_id,3,3,3
From Account_Pages a cross join Account_Roles b where  page_url like '%/SAReports.aspx?reportid=MedicalProviderReport/MedicalProviderReport%' and not exists(select * From Account_PagesInRoles c where b.role_id=c.role_id and a.page_id=c.page_id)
