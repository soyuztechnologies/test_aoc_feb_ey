@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Interface, basic'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_EY_AB_SALES as select from zey_ab_so_hdr  as hdr
association[1..*] to zey_ab_so_item as _Items on
--$projection allows us to use the field from selection list
$projection.OrderId = _Items.order_id
{
    key hdr.order_id as OrderId,
    hdr.order_no as OrderNo,
    hdr.buyer as Buyer,
    hdr.created_by as CreatedBy,
    hdr.created_on as CreatedOn,
    --exposed association
    _Items    
}
