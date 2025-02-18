@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite sales'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_EY_AB_SALES_CUBE as select from ZI_EY_AB_SALES
association[1] to ZI_EY_AB_BPA as _BusinessPartner on
$projection.Buyer = _BusinessPartner.BpId
association[1] to ZI_EY_AB_PRODUCT as _Product on 
$projection.Product = _Product.ProductId
{
    key ZI_EY_AB_SALES.OrderId,
    key ZI_EY_AB_SALES._Items.item_id as ItemId,
    ZI_EY_AB_SALES.OrderNo,
    ZI_EY_AB_SALES.Buyer,
    ZI_EY_AB_SALES.CreatedBy,
    ZI_EY_AB_SALES.CreatedOn,
    /* Associations */
    ZI_EY_AB_SALES._Items.product as Product,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'CurrencyCode'
    ZI_EY_AB_SALES._Items.amount as GrossAmount,
    ZI_EY_AB_SALES._Items.currency as CurrencyCode,
    @DefaultAggregation: #SUM
    @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
    ZI_EY_AB_SALES._Items.qty as Quantity,
    ZI_EY_AB_SALES._Items.uom as UnitOfMeasure,
    _Product,
    _BusinessPartner
}
