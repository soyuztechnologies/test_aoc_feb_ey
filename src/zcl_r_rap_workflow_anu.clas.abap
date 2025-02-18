CLASS zcl_r_rap_workflow_anu DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    INTERFACES if_swf_cpwf_callback .
    METHODS trigger_build_process IMPORTING orderno type char30.
  PROTECTED SECTION.
  PRIVATE SECTION.
  ""Interface data type for information exchange.
  TYPES: BEGIN OF context,
         orderno      TYPE string,
       END OF context,
       BEGIN OF type_context,
         order_context TYPE context,
       END OF type_context.
   ""Constants for process decision submission
    CONSTANTS:
        "To store the allowed value of the overall status of a order instance
       BEGIN OF order_status,
         open     TYPE c LENGTH 1 VALUE 'O', "Open,
         accepted TYPE c LENGTH 1 VALUE 'A', "Accepted,
         rejected TYPE c LENGTH 1 VALUE 'X', "Rejected,
         waiting  TYPE c LENGTH 1 VALUE 'W', "Awaiting Approval,
       END OF order_status,
       "    Is the Definition ID of the workflow we created in SBPA
       travel_wf_defid      TYPE if_swf_cpwf_api=>cpwf_def_id_long  VALUE 'us10.13e19585trial.melania.manageorder', " Replace this value with your workflow definition id.
       "Retention time is the time we keep the database entry post completion of Workflow instance. After the retention days are passed the database entry will be deleted automatically.
       wf_retention_days    TYPE if_swf_cpwf_api=>retention_time VALUE '30',
       "Class we created with callback interface to be used while Registering the SAP Build Process Automation Workflow using RAP Facade
       callback_class       TYPE if_swf_cpwf_api=>callback_classname VALUE  'ZCL_R_RAP_WORKFLOW_ANU', " Replace this with your callback class
       "Tells the information on where to trigger the workflow.
       consumer             TYPE string VALUE 'DEFAULT'.

ENDCLASS.



CLASS zcl_r_rap_workflow_anu IMPLEMENTATION.


  METHOD if_swf_cpwf_callback~workflow_instance_completed.

    TYPES: BEGIN OF callback_context,
             start_event TYPE type_context,
           END OF callback_context.

    DATA: callback_context TYPE callback_context.
    DATA: travelid TYPE /dmo/travel_id.

    TRY.

*       Get the API of workflow.
        DATA(cpwf_api) = cl_swf_cpwf_api_factory_a4c=>get_api_instance( ).

*       Get the Context of workflow using workflow handler ID in jason format
*       Convert it into internal data format callback_context.
        DATA(context_xstring) = cpwf_api->get_workflow_context( iv_cpwf_handle = iv_cpwf_handle ).
        DATA(outcome) = cpwf_api->get_workflow_outcome( iv_cpwf_handle = iv_cpwf_handle ).

        cpwf_api->get_context_data_from_json(
          EXPORTING
            iv_context      = context_xstring
            it_name_mapping = VALUE #( ( abap = 'start_event' json = 'startEvent' ) )
          IMPORTING
            ev_data         = callback_context
        ).

      CATCH cx_swf_cpwf_api INTO DATA(exception).
    ENDTRY.


    IF outcome IS INITIAL.
      DATA(status)    = 'X'.
    ELSE.
      status = 'A'.
    ENDIF.


  ENDMETHOD.
  METHOD trigger_build_process.
    "register the workflow
         TRY.
             MODIFY ENTITIES OF i_cpwf_inst
                ENTITY CPWFInstance "Changed#RD
                EXECUTE registerWorkflow
                FROM VALUE #( ( %key-CpWfHandle      = ''     "cl_system_uuid=>create_uuid_x16_static( )
                             %param-RetentionTime = wf_retention_days
                             %param-PaWfDefId     = travel_wf_defid
                             %param-CallbackClass = callback_class
                             %param-Consumer      = consumer ) )
                MAPPED   DATA(mapped_wf)
                FAILED   DATA(failed_wf)
                REPORTED DATA(reported_wf).

         IF mapped_wf IS NOT INITIAL.

          "Map the fields to the outgoing context.
          DATA(context)   = VALUE type_context(
                      order_context-orderno      = orderno
          ).

          " Set the workflow context for the new workflow instances
          TRY.
              DATA(lo_cpwf_api) = cl_swf_cpwf_api_factory_a4c=>get_api_instance( ).
              DATA(json_conv) = lo_cpwf_api->get_json_converter(  ).
              DATA(context_json) = json_conv->serialize( data = context ).
            CATCH cx_swf_cpwf_api.
          ENDTRY.

      "pass the Payload to workflow
           MODIFY ENTITIES OF i_cpwf_inst
            ENTITY CPWFInstance
            EXECUTE setPayload
            FROM VALUE #( ( %key-CpWfHandle = mapped_wf-cpwfinstance[ 1 ]-CpWfHandle
                           %param-context  = context_json ) )
                 MAPPED   mapped_wf
                 FAILED   failed_wf
                 REPORTED reported_wf ##NO_LOCAL_MODE.

          ENDIF.
         CATCH cx_uuid_error.
          "handle exception
        ENDTRY.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.

    trigger_build_process( orderno = '309' ).

  ENDMETHOD.

ENDCLASS.
