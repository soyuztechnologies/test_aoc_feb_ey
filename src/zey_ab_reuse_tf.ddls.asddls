@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'reuse table function'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zey_ab_reuse_tf 
with parameters
p_comp: abap.char(256)
as select from ZEY_AB_TF(p_clnt: $session.client)
{
    company_name,
    @Semantics.amount.currencyCode: 'currency_code'
    total_sales,
    currency_code,
    customer_rank
} where company_name = $parameters.p_comp
 