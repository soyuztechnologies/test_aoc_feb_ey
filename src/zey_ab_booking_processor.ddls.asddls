@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking processor projection'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZEY_AB_BOOKING_PROCESSOR as projection on ZEY_AB_BOOKING
{
    key TravelId,
    key BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _BookingStatus,
    _BookingSupplement: redirected to composition child ZEY_AB_BOOKING_SUPPL_PROCESSOR,
    _Carrier,
    _Connection,
    _Customer,
    _Travel: redirected to parent ZEY_AB_TRAVEL_PROCESSOR
}
