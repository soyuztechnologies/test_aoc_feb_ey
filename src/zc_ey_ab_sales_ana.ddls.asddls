@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales analytics consumption'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_EY_AB_SALES_ANA as select from ZI_EY_AB_SALES_CUBE
{
    key _BusinessPartner.CompanyName,
    key _BusinessPartner.Country,
    GrossAmount,
    CurrencyCode,
    Quantity,
    UnitOfMeasure
}
