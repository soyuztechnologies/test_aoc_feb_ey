@AbapCatalog.sqlViewName: 'ZATSXXCDSVIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My First cds view'
@Metadata.ignorePropagatedAnnotations: true
define view ZATS_XX_CDS_VIEW as select from zey_ab_bpa
{
    key bp_id as BpId,
    bp_role as BpRole,
    company_name as CompanyName,
    street as Street,
    country as Country,
    region as Region,
    city as City
}
