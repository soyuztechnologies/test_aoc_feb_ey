CLASS zcl_ey_ab_amdp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*  how will sap know that we want to create amdp logic in this normal abap
"  class - this class is now ready to contain SQL script code
    INTERFACES if_amdp_marker_hdb.
    INTERFACES if_oo_adt_classrun.
    CLASS-METHODS add_numbers
            IMPORTING value(a) TYPE i
                      VALUE(b) TYPE i
            EXPORTING VALUE(result) TYPE i.

    CLASS-METHODS get_customer_by_id IMPORTING
                                        value(i_bp_id) TYPE zey_ab_dte_id
                                     EXPORTING
                                        VALUE(e_res) TYPE char256.
    CLASS-METHODS get_product_mrp IMPORTING
                                    VALUE(i_tax) type i
                                  EXPORTING
                                    VALUE(otab) type zey_ab_tt_product_mrp.
    CLASS-METHODS get_total_sales for table FUNCTION ZEY_AB_TF.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EY_AB_AMDP IMPLEMENTATION.


  METHOD add_numbers BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY.
    --:= is the assignment operator
    --we use the variable in the code, we use value of (:) operator to use a variable
    result := :a + :b;

  ENDMETHOD.


  METHOD get_customer_by_id BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
                            options read-only
                            USING zey_ab_bpa .

    select concat( 'M/s ', company_name ) as company_name into e_res from zey_ab_bpa
     where bp_id = :i_bp_id ;

  ENDMETHOD.


   METHOD get_product_mrp BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
                            options read-only
                            USING zey_ab_product.
*   declare variables
    declare lv_Count integer;
    declare i integer;
    declare lv_mrp bigint;
    declare lv_price_d integer;

*   get all the products in a implicit table (like a internal table in abap)
    lt_prod = select * from zey_ab_product;

*   get the record count of the table records
    lv_count := record_count( :lt_prod );

*   loop at each record one by one and calculate the price after discount (dbtable)
    for i in 1..:lv_count do
*   calculate the MRP based on input tax
        lv_price_d := :lt_prod.price[i] * ( 100 - :lt_prod.discount[i] ) / 100;
        lv_mrp := :lv_price_d * ( 100 + :i_tax ) / 100;
*   if the MRP is more than 15k, an additional 10% discount to be applied
        if lv_mrp > 15000 then
            lv_mrp := :lv_mrp * 0.90;
        END IF ;
*   fill the otab for result (like in abap we fill another internal table with data)
        :otab.insert( (
                          :lt_prod.name[i],
                          :lt_prod.category[i],
                          :lt_prod.price[i],
                          :lt_prod.currency[i],
                          :lt_prod.discount[i],
                          :lv_price_d,
                          :lv_mrp
                      ), i );
    END FOR ;

  ENDMETHOD.


  METHOD get_total_sales by DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT
                        OPTIONS READ-ONLY
                        USING zey_ab_bpa zey_ab_so_hdr zey_ab_so_item
  .

    return select
            bpa.client,
            bpa.company_name,
            sum( item.amount ) as total_sales,
            item.currency as currency_code,
            RANK ( ) OVER ( order by sum( item.amount ) desc ) as customer_rank
     from zey_ab_bpa as bpa
    INNER join zey_ab_so_hdr as sls
    on bpa.bp_id = sls.buyer
    inner join zey_ab_so_item as item
    on sls.order_id = item.order_id
    group by bpa.client,
            bpa.company_name,
            item.currency ;

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
  ""Ctrl+Space for code completion , Shift+Enter to generate code
*        zcl_ey_ab_amdp=>add_numbers(
*          EXPORTING
*            a      = 10
*            b      = 20
*          IMPORTING
*            result = data(lv_result)
*        ).
        ""TODO: participent must check their BPA table and copy bp_id from your table
        ""Press Ctrl+Shift+A - search your bpa table and press F8
        ""Copy the bp_id from output and paste here in line 59

*        zcl_ey_ab_amdp=>get_customer_by_id(
*          EXPORTING
*            i_bp_id = '426C564A9A781EDFB988F999588A5062'
*          IMPORTING
*            e_res   = data(lv_result)
*        ).

        zcl_ey_ab_amdp=>get_product_mrp(
          EXPORTING
            i_tax = 18
          IMPORTING
            otab  = data(result)
        ).

        out->write(
          EXPORTING
            data   = result
*            name   =
*          RECEIVING
*            output =
        ).

  ENDMETHOD.
ENDCLASS.
