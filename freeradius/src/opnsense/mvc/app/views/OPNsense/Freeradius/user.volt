{#

OPNsense® is Copyright © 2014 – 2017 by Deciso B.V.
Copyright (C) 2017 Michael Muenz <m.muenz@gmail.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

#}

<script>

    $( document ).ready(function() {
        /*************************************************************************************************************
         * link grid actions
         *************************************************************************************************************/

        var usergrid = $("#grid-users").UIBootgrid({   
            'search':'/api/freeradius/user/searchUser/',
            'get':'/api/freeradius/user/getUser/',
            'set':'/api/freeradius/user/setUser/',
            'add':'/api/freeradius/user/addUser/',
            'del':'/api/freeradius/user/delUser/',
            'toggle':'/api/freeradius/user/toggleUser/'   
        });     
        
        var usegroupgrid = $("#grid-usergroups").UIBootgrid({
            'search':'/api/freeradius/usergroup/searchUsergroup',
            'get':'/api/freeradius/usergroup/getUsergroup/',
            'set':'/api/freeradius/usergroup/setUsergroup/',
            'add':'/api/freeradius/usergroup/addUsergroup/',
            'del':'/api/freeradius/usergroup/delUsergroup/',
            'toggle':'/api/freeradius/usergroup/toggleUsergroup/'
        });   
        var bandwidthrulegrid = $("#grid-bandwidthrules").UIBootgrid({
            'search':'/api/freeradius/bandwidthrule/searchBandwidthrule',
            'get':'/api/freeradius/bandwidthrule/getBandwidthrule/',
            'set':'/api/freeradius/bandwidthrule/setBandwidthrule/',
            'add':'/api/freeradius/bandwidthrule/addBandwidthrule/',
            'del':'/api/freeradius/bandwidthrule/delBandwidthrule/',
            'toggle':'/api/freeradius/bandwidthrule/toggleBandwidthrule/'
        });                   

        usergrid.on("loaded.rs.jquery.bootgrid", function () {
            usergrid.find(".command-edit").click(function () {
                $(document).data('row-id', $(this).data("row-id"));
            }).end();    
            usergrid.find(".command-copy").click(function () {
                $(document).data('row-id', $(this).data("row-id"));
            }).end();         
        });
    
        usegroupgrid.on("loaded.rs.jquery.bootgrid", function () {
            usegroupgrid.find(".command-edit").click(function () {
                $(document).data('row-id', $(this).data("row-id"));
            }).end();  
            usegroupgrid.find(".command-copy").click(function () {
                $(document).data('row-id', $(this).data("row-id"));
            }).end();              
        });  

        bandwidthrulegrid.on("loaded.rs.jquery.bootgrid", function () {
            bandwidthrulegrid.find(".command-edit").click(function () {
                $(document).data('row-id', $(this).data("row-id"));
            }).end();  
            bandwidthrulegrid.find(".command-copy").click(function () {
                $(document).data('row-id', $(this).data("row-id"));
            }).end();              
        });           

        /*************************************************************************************************************
         * Commands
         *************************************************************************************************************/

        /**
         * Reconfigure
         */
        $("#reconfigureAct").click(function(){
            $("#reconfigureAct_progress").addClass("fa fa-spinner fa-pulse");
            ajaxCall(url="/api/freeradius/service/reconfigure", sendData={}, callback=function(data,status) {
                // when done, disable progress animation.
                $("#reconfigureAct_progress").removeClass("fa fa-spinner fa-pulse");

                if (status !== "success" || data['status'] !== 'ok') {
                    BootstrapDialog.show({
                        type: BootstrapDialog.TYPE_WARNING,
                        title: "{{ lang._('Error reconfiguring FreeRADIUS') }}",
                        message: data['status'],
                        draggable: true
                    });
                } else {
                    ajaxCall(url="/api/freeradius/service/reconfigure", sendData={});
                }
            });
        });

      /*************************************************************************************************************
       * context driven input dialogs
       *************************************************************************************************************/
      ajaxGet(url='/api/freeradius/general/get', sendData={}, callback=function(data,status){
          // since our general data doesn't change during input of new users, we can control the dialog inputs
          // at once after load. No need for an "onShow" type of event here,
          // since our changes aren't driven by the dialog form itself.
          if (data.general) {
              $("#frm_dialogEditFreeRADIUSUser tr").each(function () {
                  var this_item_name = $(this).attr('id');
                  var this_item = $(this);
                  if (this_item_name) {
                      $.each(data.general, function(setting_key, setting_value){
                          var search_item = 'row_user.' + setting_key +'_';
                          if (this_item_name.startsWith(search_item) && setting_value == '0') {
                              // since our form tr rows are visible by default, we only have to hide what isn't needed
                              this_item.hide();
                          }                        
                      });
                  }
              });
              $("#frm_dialogEditFreeRADIUSUsergroup tr").each(function () {
                var this_item_name = $(this).attr('id');
                var this_item = $(this);
                if (this_item_name) {
                    $.each(data.general, function(setting_key, setting_value){
                        var search_item = 'row_usergroup.' + setting_key +'_';
                        if (this_item_name.startsWith(search_item) && setting_value == '0') {
                            // since our form tr rows are visible by default, we only have to hide what isn't needed
                            this_item.hide();
                        }                          
                    });
                }
              });   
              $("#frm_dialogEditFreeRADIUSBandwidthrule tr").each(function () {
                var this_item_name = $(this).attr('id');
                var this_item = $(this);
                if (this_item_name) {
                    $.each(data.general, function(setting_key, setting_value){
                        var search_item = 'row_bandwidthrule.' + setting_key +'_';
                        if (this_item_name.startsWith(search_item) && setting_value == '0') {
                            // since our form tr rows are visible by default, we only have to hide what isn't needed
                            this_item.hide();
                        }                          
                    });
                }
              });                         
          }
      }); 
    });
</script>

<ul class="nav nav-tabs" data-tabs="tabs" id="maintabs">
    <li class="active"><a data-toggle="tab" href="#users">{{ lang._('Users') }}</a></li>
    <li><a data-toggle="tab" href="#usergroups">{{ lang._('User Groups') }}</a></li>
    <li><a data-toggle="tab" href="#bandwidthrules">{{ lang._('Bandwidth Rules') }}</a></li>
</ul>
<div class="tab-content content-box tab-content">
    <div id="users" class="tab-pane fade in active">
        <!-- tab page "users" -->
        <table id="grid-users" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="dialogEditFreeRADIUSUser">
            <thead>
                <tr>
                    <th data-column-id="enabled" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                    <th data-column-id="username" data-type="string" data-visible="true">{{ lang._('Username') }}</th>
                    <th data-column-id="password" data-type="string" data-visible="false">{{ lang._('Password') }}</th>
                    <th data-column-id="groupname" data-type="string" data-visible="true">{{ lang._('Group Name') }}</th>
                    <th data-column-id="simultaneous" data-type="string" data-visible="false">{{ lang._('Simultaneous Use') }}</th>
                    <th data-column-id="description" data-type="string" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="ip" data-type="string" data-visible="true">{{ lang._('IP Address') }}</th>
                    <th data-column-id="subnet" data-type="string" data-visible="false">{{ lang._('Subnet') }}</th>
                    <th data-column-id="vlan" data-type="string" data-visible="false">{{ lang._('VLAN ID') }}</th>
                    <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}</th>
                    <th data-column-id="commands" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody></tbody>
            <tfoot>
                <tr>
                    <td></td>
                    <td>
                        <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                        <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
                    </td>
                </tr>
            </tfoot>
        </table>
    </div>   
    <div id="usergroups" class="tab-pane">
        <!-- tab page "usergroups" -->
        <table id="grid-usergroups" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="dialogEditFreeRADIUSUsergroup">
            <thead>
                <tr>
                    <th data-column-id="enabled" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                    <th data-column-id="groupname" data-type="string" data-visible="true">{{ lang._('Group Name') }}</th>
                    <th data-column-id="simultaneous" data-type="string" data-visible="false">{{ lang._('Simultaneous Use') }}</th>
                    <th data-column-id="description" data-type="string" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="authtype" data-type="string" data-visible="true">{{ lang._('Authentication Type') }}</th>
                    <th data-column-id="replymessage" data-type="string" data-visible="true">{{ lang._('Reply Message') }}</th>
                    <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}</th>
                    <th data-column-id="commands" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody></tbody>
            <tfoot>
                <tr>
                    <td></td>
                    <td>
                        <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                        <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
                    </td>
                </tr>
            </tfoot>
        </table>
    </div>     
    <div id="bandwidthrules" class="tab-pane">
        <!-- tab page "bandwidthrules" -->
        <table id="grid-bandwidthrules" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="dialogEditFreeRADIUSBandwidthrule">
            <thead>
                <tr>
                    <th data-column-id="enabled" data-width="6em" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                    <th data-column-id="uploadbandwidth" data-type="number">{{ lang._('Upload Bandwidth') }}</th>
                    <th data-column-id="uploadmetric" data-type="string">{{ lang._('Upload Metric') }}</th>
                    <th data-column-id="downloadbandwidth" data-type="number">{{ lang._('Download Bandwidth') }}</th>
                    <th data-column-id="downloadmetric" data-type="string">{{ lang._('Download Metric') }}</th>                    
                    <th data-column-id="description" data-type="string">{{ lang._('Description') }}</th>
                    <th data-column-id="uuid" data-type="string" data-identifier="true"  data-visible="false">{{ lang._('ID') }}</th>
                    <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody></tbody>
            <tfoot>
                <tr>
                    <td></td>
                    <td>
                        <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                        <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
                    </td>
                </tr>
            </tfoot>
        </table>
    </div>       
    <div class="col-md-12">
        <hr/>
        <button class="btn btn-primary" id="reconfigureAct" type="button"><b>{{ lang._('Apply') }}</b> <i id="reconfigureAct_progress" class=""></i></button>
        <br/><br/>
    </div>  
</div>

<!-- User -->

<div class="modal fade" id="dialogEditFreeRADIUSUser" tabindex="-1" role="dialog" aria-labelledby="dialogEditFreeRADIUSUserLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="dialogEditFreeRADIUSUserLabel">{{ lang._("Edit User") }}</h4>
            </div>
            <div class="modal-body">
                <form id="frm_dialogEditFreeRADIUSUser">
                    <div class="table-responsive">
                        <table class="table table-striped table-condensed">
                            <colgroup>
                                <col class="col-md-3" />
                                <col class="col-md-6" />
                                <col class="col-md-6" />
                            </colgroup>
                            <tbody>
                                <tr>
                                    <td>
                                        <a href="#"><i class="fa fa-toggle-off text-danger" id="show_advanced_formDialogdialogEditFreeRADIUSUser"></i></a>
                                        <small>{{ lang._('advanced mode') }}</small>
                                    </td>
                                    <td colspan="2" style="text-align:right;">
                                        <small>{{ lang._('full help') }}</small>
                                        <a href="#"><i class="fa fa-toggle-off text-danger" id="show_all_help_formDialogdialogEditFreeRADIUSUser"></i></a>
                                    </td>
                                </tr>
                                <!-- user.enabled -->
                                <tr id="row_user.enabled">
                                    <td>
                                        <div class="control-label" id="control_label_user.enabled">
                                            <a id="help_for_user.enabled" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Enabled") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="user.enabled" type="checkbox">
                                        <div class="hidden" data-for="help_for_user.enabled">
                                            <small>{{ lang._("This will enable or disable the user account.") }}</small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.enabled"></span>
                                    </td>
                                </tr>
                                <!-- user.username -->
                                <tr id="row_user.username">
                                    <td>
                                        <div class="control-label" id="control_label_user.username">
                                            <a id="help_for_user.username" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Username") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="user.username" type="text" class="form-control">
                                        <div class="hidden" data-for="help_for_user.username">
                                            <small>
                                                {{ lang._("Set the unique username for the user. Allowed characters are 0-9, a-z, A-Z, and ._-") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.username"></span>
                                    </td>
                                </tr>
                                <!-- user.password -->
                                <tr id="row_user.password">
                                    <td>
                                        <div class="control-label" id="control_label_user.password">
                                            <a id="help_for_user.password" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Password") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="user.password" type="password" class="form-control" >
                                        <div class="hidden" data-for="help_for_user.password">
                                            <small>
                                                {{ lang._("Set the password for the user. Allowed characters are 0-9, a-z, A-Z, and ,._-!$%/()+#= with up to 128 characters.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.password"></span>
                                    </td>
                                </tr>     
                                <!-- user.groupname -->
                                <tr id="row_user.groupname">
                                    <td>
                                        <div class="control-label" id="control_label_user.groupname">
                                            <a id="help_for_user.groupname" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Group Name") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <select id="user.groupname" class="selectpicker"></select>
                                        <div class="hidden" data-for="help_for_user.groupname">
                                            <small>
                                                {{ lang._("Set the unique groupname for the user. Allowed characters are 0-9, a-z, A-Z, and ._-") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.groupname"></span>
                                    </td>
                                </tr>     
                                <!-- user.description -->
                                <tr id="row_user.description">
                                    <td>
                                        <div class="control-label" id="control_label_user.description">
                                            <a id="help_for_user.description" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Description") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="user.description" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_user.description">
                                            <small>
                                                {{ lang._("Given name, last name, or anything you need to describe.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.description"></span>
                                    </td>
                                </tr>  
                                <!-- user.simultaneous -->
                                <tr id="row_user.simultaneous">
                                    <td>
                                        <div class="control-label" id="control_label_user.simultaneous">
                                            <a id="help_for_user.simultaneous" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Simultaneous Use") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="user.simultaneous" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_user.simultaneous">
                                            <small>
                                                {{ lang._("Set the simultaneous use for the user. its range from 1 to 10. if you want to remove it, leave it empty.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.simultaneous"></span>
                                    </td>
                                </tr>                                    
                                <!-- user.authtype -->
                                <tr id="row_user.authtype">
                                    <td>
                                        <div class="control-label" id="control_label_user.authtype">
                                            <a id="help_for_user.authtype" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Authentication Type") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <select id="user.authtype" class="selectpicker"></select>
                                        <div class="hidden" data-for="help_for_user.authtype">
                                            <small>
                                                {{ lang._("Set the authentication type of each user group.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.authtype"></span>
                                    </td>
                                </tr>      
                                <!-- user.replymessage -->
                                <tr id="row_user.replymessage">
                                    <td>
                                        <div class="control-label" id="control_label_user.replymessage">
                                            <a id="help_for_user.replymessage" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Reply Message") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="user.replymessage" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_user.replymessage">
                                            <small>
                                                {{ lang._("Reply message return a message after authentication for user group, empty message does not involved in the process.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.replymessage"></span>
                                    </td>
                                </tr>                                        
                                <!-- user.ip -->
                                <tr id="row_user.ip">
                                    <td>
                                        <div class="control-label" id="control_label_user.ip">
                                            <a id="help_for_user.ip" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("IP Address") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="user.ip" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_user.ip">
                                            <small>
                                                {{ lang._("Set the IP address the user should receive.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.ip"></span>
                                    </td>
                                </tr>      
                                <!-- user.subnet -->
                                <tr id="row_user.subnet">
                                    <td>
                                        <div class="control-label" id="control_label_user.subnet">
                                            <a id="help_for_user.subnet" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Subnetmask") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="user.subnet" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_user.subnet">
                                            <small>
                                                {{ lang._("Subnet to receive, e.g. 255.255.255.0") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.subnet"></span>
                                    </td>
                                </tr>    
                                <!-- user.route -->
                                <tr id="row_user.route">
                                    <td>
                                        <div class="control-label" id="control_label_user.route">
                                            <a id="help_for_user.route" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Routes") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <select id="user.route" multiple="multiple" class="tokenize"
                                            data-width="348px"
                                            data-allownew="true"
                                            data-live-search="true">
                                        </select>
                                        <div class="hidden" data-for="help_for_user.route">
                                            <small>
                                                {{ lang._("Add routes in CIDR notation, e.g. 192.168.2.0/24. Multiple entries are allowed") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.route"></span>
                                    </td>
                                </tr>    
                                <!-- user.ip6 -->
                                <tr id="row_user.ip6">
                                    <td>
                                        <div class="control-label" id="control_label_user.ip6">
                                            <a id="help_for_user.ip6" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("IPv6 Address") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="user.ip6" type="text" class="form-control">
                                        <div class="hidden" data-for="help_for_user.ip6">
                                            <small>
                                                {{ lang._("Set the IPv6 address the user should receive.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.ip6"></span>
                                    </td>
                                </tr>    
                                <!-- user.vlan -->
                                <tr id="row_user.vlan">
                                    <td>
                                        <div class="control-label" id="control_label_user.vlan">
                                            <a id="help_for_user.vlan" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("VLAN ID") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="user.vlan" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_user.vlan">
                                            <small>
                                                {{ lang._("VLAN ID the user receives, e.g. for 802.1X. Leave empty if you don't know what it is.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.vlan"></span>
                                    </td>
                                </tr>       
                                <!-- user.mikrotik -->
                                <script>
                                    $( document ).ready(function() {
                                        $('#user_mikrotik_box').click(function(event) {
                                            $('#user_mikrotik_box').parent().hide();
                                            $('#user_mikrotik_body').show();
                                        });
                                    });      
                                </script>                                   
                                <tr id="row_user.mikrotik" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_user.mikrotik">
                                            <a id="help_for_user.mikrotik" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Mikrotik VLAN") }}</b>
                                        </div>
                                    </td>
                                    <td>                                                 
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="user_mikrotik_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show Mikrotik VLAN configuration") }}
                                                    </div>
                                                    <div id="user_mikrotik_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("Mikrotik VLAN configuration") }}
                                                        <br/><br/>
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="user_mikrotik_table"> 
                                                            <thead>
                                                                <tr>
                                                                    <th>{{ lang._("VLAN ID") }}</th>
                                                                    <th>{{ lang._("VLAN Type") }}</th>
                                                                </tr>                                      
                                                            </thead>                                                              
                                                            <tbody>                                                                       
                                                                <tr>                              
                                                                    <td>
                                                                        <input id="user.mikrotik_vlan_id_number" type="text" class="form-control" >  
                                                                    </td>
                                                                    <td>    
                                                                        <input id="user.mikrotik_vlan_id_type" type="text" class="form-control" >                                       
                                                                    </td>                                      
                                                                </tr>                                                                    
                                                            </tbody>
                                                        </table>                         
                                                    </div>
                                                </td>
                                            </tr>
                                        </table> 
                                        <div class="hidden" data-for="help_for_user.mikrotik">
                                            <small>
                                                {{ lang._("Set the Mikrotik VLAN ID and type attribute. Mikrotik uses own attributes for VLAN assignment and for VLAN type use a value of 0 is fine.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.mikrotik"></span>
                                    </td>
                                </tr>   
                                <!-- user.wispr -->
                                <!--
                                <script>
                                    $( document ).ready(function() {
                                        $('#user_wispr_box').click(function(event) {
                                            $('#user_wispr_box').parent().hide();
                                            $('#user_wispr_body').show();
                                        });                          
                                    });      
                                </script>                                 
                                <tr id="row_user.wispr" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_user.wispr">
                                            <a id="help_for_user.wispr" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("WISPr Bandwidth") }}</b>
                                        </div>
                                    </td>
                                    <td>       
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="user_wispr_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show WISPr Bandwidth configuration") }}
                                                    </div>
                                                    <div id="user_wispr_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("WISPr Bandwidth configuration") }}
                                                        <br/><br/>
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="user_wispr_table">                                                               
                                                            <tbody>
                                                                <tr>
                                                                    <th>{{ lang._("Minimum Upload") }}</th>
                                                                    <th>{{ lang._("Maximum Upload") }}</th>
                                                                </tr>                                                                         
                                                                <tr>                              
                                                                    <td>
                                                                        <input id="user.wispr_bw_min_up" type="text" class="form-control" >  
                                                                    </td>
                                                                    <td>    
                                                                        <input id="user.wispr_bw_max_up" type="text" class="form-control" >                                       
                                                                    </td>                                      
                                                                </tr>
                                                                <tr>
                                                                    <th>{{ lang._("Minimum Download") }}</th>
                                                                    <th>{{ lang._("Maximum Download") }}</th>
                                                                </tr> 
                                                                <tr>                              
                                                                    <td>
                                                                        <input id="user.wispr_bw_min_down" type="text" class="form-control" >  
                                                                    </td>
                                                                    <td>    
                                                                        <input id="user.wispr_bw_max_down" type="text" class="form-control" >                                       
                                                                    </td>                                      
                                                                </tr>                                                                        
                                                            </tbody>
                                                        </table>                         
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>       
                                        <div class="hidden" data-for="help_for_user.wispr">
                                            <small>
                                                {{ lang._("Set the Bandwidth for WISPr attribute. The value is treated as bits/s.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.wispr"></span>
                                    </td>
                                </tr> 
                                -->   
                                <!-- user.chillispot -->
                                <!--
                                <script>
                                    $( document ).ready(function() {                        
                                        $('#user_chillispot_box').click(function(event) {
                                            $('#user_chillispot_box').parent().hide();
                                            $('#user_chillispot_body').show();
                                        });
                                    });      
                                </script>                                    
                                <tr id="row_user.chillispot" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_user.chillispot">
                                            <a id="help_for_user.chillispot" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("ChilliSpot Bandwidth") }}</b>
                                        </div>
                                    </td>
                                    <td>      
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="user_chillispot_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show ChilliSpot Bandwith configuration") }}
                                                    </div>
                                                    <div id="user_chillispot_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("ChilliSpot Bandwith configuration") }}
                                                        <br/><br/>
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="user_chillispot_table">   
                                                            <thead>
                                                                <tr>
                                                                    <th>{{ lang._("Maximum Upload") }}</th>
                                                                    <th>{{ lang._("Maximum Download") }}</th>
                                                                </tr>                                     
                                                            </thead>                                                            
                                                            <tbody>                                                                        
                                                                <tr>                              
                                                                    <td>
                                                                        <input id="user.chillispot_bw_max_up" type="text" class="form-control" >  
                                                                    </td>
                                                                    <td>    
                                                                        <input id="user.chillispot_bw_max_down" type="text" class="form-control" >                                       
                                                                    </td>                                      
                                                                </tr>                                                                    
                                                            </tbody>
                                                        </table>                         
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>   
                                        <div class="hidden" data-for="help_for_user.chillispot">
                                            <small>
                                                {{ lang._("Set the Bandwidth for ChilliSpot attribute. The value is treated as kbits/s.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.chillispot"></span>
                                    </td>
                                </tr>   
                                -->
                                <!-- user.logintime -->
                                <script>
                                    $(document).ready(function() {                
                                        function process_logintimte_data() {
                                            var _days = "", _start_time = "", _end_time = "", _login_time = "";
                
                                            $('#user_logintimes_table > tbody  > tr').each(function() {
                                                _days = $(this).find('.days').val();
                                                _start_time = $(this).find('.start_time').val().replace(':', '');
                                                _end_time = $(this).find('.end_time').val().replace(':', '');
                
                                                if (_login_time) {
                                                    _login_time += ",";
                                                }
                
                                                if (_start_time === "" || _end_time === "") {
                                                    _login_time += _days;
                                                } else {
                                                    _login_time += _days + _start_time + '-' + _end_time;
                                                }                                
                                            });
                                            $('.logintime').val(_login_time);
                
                                            var ui_start_date = $('#user_logindates_table > tbody > tr > td > .ui_start_date').val();
                                            var ui_end_date = $('#user_logindates_table > tbody > tr > td > .ui_end_date').val();
                                            $('#user_logindates_table > tbody > tr > td > .start_date').val(ui_start_date === "" ? "" : new Date(ui_start_date).getTime() / 1000);
                                            $('#user_logindates_table > tbody > tr > td > .end_date').val(ui_end_date === "" ? "" : new Date(ui_end_date).getTime() / 1000);
                                        };
                
                                        function _fill_logintime_elements(arr) {
                                            // regex patterns
                                            var days_re = /[^-0-9]/g;
                                            var times_re = /[-0-9]/g;
                
                                            // days
                                            arr.forEach(function(element) {
                                                if (element) { 
                                                    // days
                                                    m = element.match(days_re);
                                                    if (m) {
                                                        days = m.join('');
                                                        $('#user_logintimes_table > tbody').append("<tr><td><div style='cursor:pointer;' class='act-removerow btn btn-default btn-xs' alt='remove'><i class='fa fa-minus fa-fw'></i></div></td><td><select class='days {{style|default('')}}' data-width='{{width|default('120px')}}'><option value='su'>Sunday</option><option value='mo'>Monday</option><option value='tu'>Tuesday</option><option value='we'>Wednesday</option><option value='th'>Thursday</option><option value='fr'>Friday</option><option value='sa'>Saturday</option><option value='wk'>Week Days</option><option value='any'>Any Day</option><option value='al'>All Days</option></select></td><td><input type='text' class='start_time form-control' size='1px'></td><td><input type='text' class='end_time form-control' size='1px'></td></tr>");
                                                        $('#user_logintimes_table > tbody > tr:last > td > .days').val(days);
                                                    }
                                                    // start_time and end_time
                                                    m = element.match(times_re);
                                                    if (m) {
                                                        times = m.join('').split('-');
                                                        times.forEach(function(part, index, theArray) {
                                                            // put ':' character to each item in array in the form of time
                                                            theArray[index] = [part.slice(0, 2), ':', part.slice(2)].join('');
                                                        });
                                                        $('#user_logintimes_table > tbody > tr:last > td > .start_time').val(times[0]); //start_time
                                                        $('#user_logintimes_table > tbody > tr:last > td > .end_time').val(times[1]); // end_time  
                                                    }
                                                }
                                            });
                                        }
                
                                        function fill_logintime_elements() {
                                            $('#user_logintimes_table > tbody').empty();
                
                                            var user_id = $(document).data('row-id');
                                            if (user_id) {
                                                var _url = '/api/freeradius/user/getUser/' + user_id;
                
                                                ajaxGet(url=_url, sendData={}, callback=function(data,status) { 
                                                    if (data === undefined && data === null) {
                                                        return;
                                                    }
                                                    if (data.user.logintime_value) {
                                                        var arr = data.user.logintime_value.split(',');
                                                        _fill_logintime_elements(arr);
                                                    }
                                                    $(".act-removerow").click(removeRow); 
                                                });
                                            }
                                        }
                
                                        function removeRow() {
                                            $(this).parent().parent().remove();
                                            process_logintimte_data();
                                        }  
                
                                        $('#dialogEditFreeRADIUSUser').on('shown.bs.modal', function (e) { fill_logintime_elements(); });
                                        $('#user_logindates_table > tbody > tr > td > .ui_start_date').on('change', function (e) { process_logintimte_data(); });
                                        $('#user_logindates_table > tbody > tr > td > .ui_end_date').on('change', function (e) { process_logintimte_data(); });
                
                                        $('#user_logintimes_table > tbody').on('change', '.days', function (e) { process_logintimte_data(); });
                                        $('#user_logintimes_table > tbody').on('input', '.start_time', function (e) { process_logintimte_data(); });
                                        $('#user_logintimes_table > tbody').on('input', '.end_time', function (e) { process_logintimte_data(); });  
                
                                        $('#user_logintime_addnew').click(function(){
                                            // copy last row and reset values
                                            $('#user_logintimes_table > tbody').append("<tr><td><div style='cursor:pointer;' class='act-removerow btn btn-default btn-xs' alt='remove'><i class='fa fa-minus fa-fw'></i></div></td><td><select class='days' data-width='120px'><option value='su'>Sunday</option><option value='mo'>Monday</option><option value='tu'>Tuesday</option><option value='we'>Wednesday</option><option value='th'>Thursday</option><option value='fr'>Friday</option><option value='sa'>Saturday</option><option value='wk'>Week Days</option><option value='any'>Any Day</option><option value='al'>All Days</option></select></td><td><input type='text' class='start_time form-control' size='1px'></td><td><input type='text' class='end_time form-control' size='1px'></td></tr>");
                                            $(".act-removerow").click(removeRow);
                                            process_logintimte_data();
                                        });

                                        $('#user_logintime_box').click(function(event) {
                                            $('#user_logintime_box').parent().hide();
                                            $('#user_logintime_body').show();
                                        });                                        
                                    });      
                                </script>                                    
                                <tr id="row_user.logintime" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_user.logintime">
                                            <a id="help_for_user.logintime" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Login Time") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="user_logintime_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show login time configuration") }}
                                                    </div>
                                                    <div id="user_logintime_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("Login Time configuration") }}
                                                        <br/><br/>
                                                        <input type="text" id="user.logintime_value" class="logintime hidden form-control" readonly="readonly">
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="user_logindates_table">  
                                                            <thead>
                                                                <tr>
                                                                    <th>{{ lang._("Start Date") }}</th>
                                                                    <th>{{ lang._("End Date") }}</th>
                                                                </tr>
                                                            </thead>    
                                                            <tbody>                                                                          
                                                                <tr>                              
                                                                    <td>    
                                                                        <input id="user.logintime_ui_start_date" type="text" class="ui_start_date form-control" placeholder="YYYY/MM/dd"> 
                                                                        <input id="user.logintime_start_date" type="text" class="start_date hidden form-control" >                                       
                                                                    </td>
                                                                    <td>
                                                                        <input id="user.logintime_ui_end_date" type="text" class="ui_end_date form-control" placeholder="YYYY/MM/dd">
                                                                        <input id="user.logintime_end_date" type="text" class="end_date hidden form-control" >
                                                                    </td>
                                                                </tr>
                                                            </tbody>                                                            
                                                        </table>  
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="user_logintimes_table">      
                                                            <thead>
                                                                <tr>
                                                                    <th></th>
                                                                    <th>{{ lang._("Days") }}</th>
                                                                    <th>{{ lang._("From") }}</th>
                                                                    <th>{{ lang._("To") }}</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>                                                                          
                                                            </tbody>
                                                            <tfoot>
                                                                <tr>
                                                                    <td colspan="4">
                                                                        <div id="user_logintime_addnew" style="cursor:pointer;" class="btn btn-default btn-xs" alt="add"><i class="fa fa-plus fa-fw"></i></div>
                                                                    </td>
                                                                </tr>
                                                            </tfoot>
                                                        </table>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                        <div class="hidden" data-for="help_for_user.logintime">
                                            <small>
                                                {{ lang._("Set the Login-Time. This can be used by the Captive Portal.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.logintime"></span>
                                    </td>
                                </tr>  
                                <!-- user.bandwidthlimit -->
                                <tr id="row_user.bandwidthlimit" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_user.bandwidthlimit">
                                            <a id="help_for_user.bandwidthlimit" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Max Bandwidth Limit") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <select id="user.bandwidthlimit" class="selectpicker"></select>
                                        <div class="hidden" data-for="help_for_user.bandwidthlimit">
                                            <small>
                                                {{ lang._("Set the bandwidth limit of each user group.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.bandwidthlimit"></span>
                                    </td>
                                </tr>                                  
                                <!-- user.sessionlimit -->
                                <script>
                                    $( document ).ready(function() {                
                                        function process_sessionlimit_data(element) {
                                            var _sessionlimit = $("#user_sessionlimit_table > tbody > tr").find(element).val();
                                            if (_sessionlimit) {
                                                var isValid = false;
                                                var type = element.replace('.', '').replace('sessionlimit_ui', '');
                                                if (type === 'hourly') {
                                                    isValid = (_sessionlimit.search(/^\d{2}:\d{2}:\d{2}$/) !== -1) &&
                                                        (_sessionlimit.substr(0,2) >= 0 && _sessionlimit.substr(0,2) <= 0) &&
                                                        (_sessionlimit.substr(3,2) >= 0 && _sessionlimit.substr(3,2) <= 59) &&
                                                        (_sessionlimit.substr(6,2) >= 0 && _sessionlimit.substr(6,2) <= 59);
                                                } else if (type === 'daily') {
                                                    isValid = (_sessionlimit.search(/^\d{2}:\d{2}:\d{2}$/) !== -1) &&
                                                        (_sessionlimit.substr(0,2) >= 0 && _sessionlimit.substr(0,2) <= 24) &&
                                                        (_sessionlimit.substr(3,2) >= 0 && _sessionlimit.substr(3,2) <= 59) &&
                                                        (_sessionlimit.substr(6,2) >= 0 && _sessionlimit.substr(6,2) <= 59);
                                                } else if (type === 'weekly' || type === 'monthly' || type === 'account') {
                                                    var max = 0;
                                                    if (type === 'weekly') {
                                                        max = 168;  // 7 * 24
                                                    } else if (type === 'monthly') {
                                                        max = 720; // 30 * 24
                                                    } else if (type === 'account') { 
                                                        max = 8760; // 365 * 24
                                                    }
                                                    var doubleDigit = (_sessionlimit.search(/^\d{2}:\d{2}:\d{2}$/) !== -1); 
                                                    var tripleDigit = (_sessionlimit.search(/^\d{3}:\d{2}:\d{2}$/) !== -1); 
                                                    var quadrupleDigit = (_sessionlimit.search(/^\d{4}:\d{2}:\d{2}$/) !== -1); 
                                                    if (doubleDigit) {
                                                        isValid = (_sessionlimit.substr(0,2) >= 0 && _sessionlimit.substr(0,2) <= max) &&
                                                            (_sessionlimit.substr(3,2) >= 0 && _sessionlimit.substr(3,2) <= 59) &&
                                                            (_sessionlimit.substr(6,2) >= 0 && _sessionlimit.substr(6,2) <= 59);
                                                    } else if (tripleDigit) {
                                                        isValid = (_sessionlimit.substr(0,3) >= 0 && _sessionlimit.substr(0,3) <= max) &&
                                                            (_sessionlimit.substr(4,2) >= 0 && _sessionlimit.substr(4,2) <= 59) &&
                                                            (_sessionlimit.substr(7,2) >= 0 && _sessionlimit.substr(7,2) <= 59);
                                                    } else if (quadrupleDigit && type === 'account') {
                                                        isValid = (_sessionlimit.substr(0,4) >= 0 && _sessionlimit.substr(0,4) <= max) &&
                                                            (_sessionlimit.substr(5,2) >= 0 && _sessionlimit.substr(5,2) <= 59) &&
                                                            (_sessionlimit.substr(8,2) >= 0 && _sessionlimit.substr(8,2) <= 59);
                                                    }
                                                } 
                                                if (isValid) {
                                                    var a = _sessionlimit.split(':');
                                                    _sessionlimit = (+a[0]) * 60 * 60 + (+a[1]) * 60 + (+a[2]); 
                                                    _sessionlimit = _sessionlimit <= 0 ? "" : _sessionlimit.toString();
                                                } else {
                                                    _sessionlimit = '';
                                                }
                                            }
                                            $("#user_sessionlimit_table > tbody > tr > td").find(element.replace('_ui', '')).val(_sessionlimit);
                                        };
                
                                        $('#dialogEditFreeRADIUSUser').on('shown.bs.modal', function (e) { 
                                            process_sessionlimit_data('.hourlysessionlimit_ui');
                                            process_sessionlimit_data('.dailysessionlimit_ui');
                                            process_sessionlimit_data('.weeklysessionlimit_ui');
                                            process_sessionlimit_data('.monthlysessionlimit_ui');
                                            process_sessionlimit_data('.accountsessionlimit_ui'); 
                                        });

                                        $("#user_sessionlimit_table > tbody > tr").on('input', '.hourlysessionlimit_ui', function (e) { process_sessionlimit_data('.hourlysessionlimit_ui'); });
                                        $("#user_sessionlimit_table > tbody > tr").on('input', '.dailysessionlimit_ui', function (e) { process_sessionlimit_data('.dailysessionlimit_ui'); });
                                        $("#user_sessionlimit_table > tbody > tr").on('input', '.weeklysessionlimit_ui', function (e) { process_sessionlimit_data('.weeklysessionlimit_ui'); });
                                        $("#user_sessionlimit_table > tbody > tr").on('input', '.monthlysessionlimit_ui', function (e) { process_sessionlimit_data('.monthlysessionlimit_ui'); });
                                        $("#user_sessionlimit_table > tbody > tr").on('input', '.accountsessionlimit_ui', function (e) { process_sessionlimit_data('.accountsessionlimit_ui'); });

                                        $("#user_sessionlimit_table > tbody > tr > td > input[name='sessionlimitradio']").on('change', function (e) {
                                            if($(this).is(':checked')) {
                                                $("#user_sessionlimit_table > tbody > tr > td > input[type='text']").val('');
                                                $("#user_sessionlimit_table > tbody > tr > td > input.sessionlimit_ui").attr('readonly', false);
                                                $("#user_sessionlimit_table > tbody > tr > td > input.sessionlimit_ui").not($(this).parent().nextAll().children('input.sessionlimit_ui')).attr('readonly', true);
                                            }
                                         });

                                        $('#user_sessionlimit_box').click(function(event) {
                                            $('#user_sessionlimit_box').parent().hide();
                                            $('#user_sessionlimit_body').show();
                                        });                                         
                                    });      
                                </script>                                  
                                <tr id="row_user.sessionlimit" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_user.sessionlimit">
                                            <a id="help_for_user.sessionlimit" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Max Session Limit") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="user_sessionlimit_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show max  session limit configuration") }}
                                                    </div>
                                                    <div id="user_sessionlimit_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("Max session limit configuration") }}
                                                        <br/><br/>
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="user_sessionlimit_table">                                                                                         
                                                            <tbody>                                                                          
                                                                <tr>
                                                                    <td><input type="radio" name="sessionlimitradio" class="form-control" checked></td>                            
                                                                    <td>{{ lang._("Hourly") }}</td>
                                                                    <td><input id="user.hourlysessionlimit_ui" type="text" class="sessionlimit_ui hourlysessionlimit_ui form-control" placeholder="00:mm:ss"></td>
                                                                    <td><input id="user.hourlysessionlimit" type="text" class="hourlysessionlimit form-control" size="13" readonly="readonly"></td> 
                                                                </tr>  
                                                                <tr>  
                                                                    <td><input type="radio" name="sessionlimitradio" class="form-control"></td>                               
                                                                    <td>{{ lang._("Daily") }}</td>
                                                                    <td><input id="user.dailysessionlimit_ui" type="text" class="sessionlimit_ui dailysessionlimit_ui form-control" readonly="readonly" placeholder="HH:mm:ss"></td>
                                                                    <td><input id="user.dailysessionlimit" type="text" class="dailysessionlimit form-control" size="13" readonly="readonly"></td>
                                                                </tr>        
                                                                <tr> 
                                                                    <td><input type="radio" name="sessionlimitradio" class="form-control"></td>                            
                                                                    <td>{{ lang._("Weekly") }}</td>
                                                                    <td><input id="user.weeklysessionlimit_ui" type="text" class="sessionlimit_ui weeklysessionlimit_ui form-control" readonly="readonly" placeholder="[HH, HHH]:mm:ss"></td>
                                                                    <td><input id="user.weeklysessionlimit" type="text" class="weeklysessionlimit form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr>
                                                                    <td><input type="radio" name="sessionlimitradio" class="form-control"></td>                             
                                                                    <td>{{ lang._("Monthly") }}</td>
                                                                    <td><input id="user.monthlysessionlimit_ui" type="text" class="sessionlimit_ui monthlysessionlimit_ui form-control" readonly="readonly" placeholder="[HH, HHH]:mm:ss"></td>
                                                                    <td><input id="user.monthlysessionlimit" type="text" class="monthlysessionlimit form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr>  
                                                                    <td></td>                          
                                                                    <td>{{ lang._("Account") }}</td>
                                                                    <td><input id="user.accountsessionlimit_ui" type="text" class="accountsessionlimit_ui form-control" placeholder="[HH, HHH, HHHH]:mm:ss"></td>
                                                                    <td><input id="user.accountsessionlimit" type="text" class="accountsessionlimit form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>                                                                                                                                                                                                                                                                                              
                                                            </tbody>
                                                        </table>                        
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>     
                                        <div class="hidden" data-for="help_for_user.sessionlimit">
                                            <small>
                                                {{ lang._("Set the maximum hourly, daily, weekly, monthly and account session limit. This can be used by the Captive Portal.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.sessionlimit"></span>
                                    </td>
                                </tr>                                 
                                <!-- user.trafficlimit -->
                                <script>
                                    $( document ).ready(function() {   
                                        function formatBytes(bytes, decimals) {
                                            var k = 1024, dm = decimals <= 0 ? 0 : decimals || 2,
                                                sizes = ['Bytes', 'KBytes', 'MBytes', 'GBytes', 'TBytes', 'PBytes', 'EBytes', 'ZBytes', 'YBytes'],
                                                i = Math.floor(Math.log(bytes) / Math.log(k));
                                            return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
                                        }

                                        function process_trafficlimit_data(element) {
                                            var _trafficlimit = $("#user_trafficlimit_table > tbody > tr").find(element).val();
                                            if (_trafficlimit.search(/^\d+$/) !== -1) {
                                                _trafficlimit = Number(_trafficlimit) <= 0 ? "" : formatBytes(Number(_trafficlimit), 4);
                                            } else {
                                                _trafficlimit = '';
                                            }
                                            $("#user_trafficlimit_table > tbody > tr > td").find(element + '_ui').val(_trafficlimit);
                                        };
                
                                        $('#dialogEditFreeRADIUSUser').on('shown.bs.modal', function (e) { 
                                            process_trafficlimit_data('.hourlytrafficlimit');
                                            process_trafficlimit_data('.dailytrafficlimit');
                                            process_trafficlimit_data('.weeklytrafficlimit');
                                            process_trafficlimit_data('.monthlytrafficlimit');
                                            process_trafficlimit_data('.accounttrafficlimit'); 
                                        });

                                        $("#user_trafficlimit_table > tbody > tr").on('input', '.hourlytrafficlimit', function (e) { process_trafficlimit_data('.hourlytrafficlimit'); });
                                        $("#user_trafficlimit_table > tbody > tr").on('input', '.dailytrafficlimit', function (e) { process_trafficlimit_data('.dailytrafficlimit'); });
                                        $("#user_trafficlimit_table > tbody > tr").on('input', '.weeklytrafficlimit', function (e) { process_trafficlimit_data('.weeklytrafficlimit'); });
                                        $("#user_trafficlimit_table > tbody > tr").on('input', '.monthlytrafficlimit', function (e) { process_trafficlimit_data('.monthlytrafficlimit'); });
                                        $("#user_trafficlimit_table > tbody > tr").on('input', '.accounttrafficlimit', function (e) { process_trafficlimit_data('.accounttrafficlimit'); });

                                        $("#user_trafficlimit_table > tbody > tr > td > input[name='trafficlimitradio']").on('change', function (e) {
                                            if($(this).is(':checked')) {
                                                $("#user_trafficlimit_table > tbody > tr > td > input[type='text']").val('');
                                                $("#user_trafficlimit_table > tbody > tr > td > input.trafficlimit").attr('readonly', false);
                                                $("#user_trafficlimit_table > tbody > tr > td > input.trafficlimit").not($(this).parent().nextAll().children('input.trafficlimit')).attr('readonly', true);
                                            }
                                         });                                        

                                        $('#user_trafficlimit_box').click(function(event) {
                                            $('#user_trafficlimit_box').parent().hide();
                                            $('#user_trafficlimit_body').show();
                                        });                                         
                                    });      
                                </script>                                  
                                <tr id="row_user.trafficlimit" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_user.trafficlimit">
                                            <a id="help_for_user.trafficlimit" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Max Traffic Limit") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="user_trafficlimit_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show max  traffic limit configuration") }}
                                                    </div>
                                                    <div id="user_trafficlimit_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("Max traffic limit configuration") }}
                                                        <br/><br/>
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="user_trafficlimit_table">                                                                                          
                                                            <tbody>                                                                          
                                                                <tr>    
                                                                    <td><input type="radio" name="trafficlimitradio" class="form-control" checked></td>                        
                                                                    <td>{{ lang._("Hourly") }}</td>
                                                                    <td><input id="user.hourlytrafficlimit" type="text" class="trafficlimit hourlytrafficlimit form-control" placeholder="Enter in Bytes"></td>
                                                                    <td><input id="user.hourlytrafficlimit_ui" type="text" class="hourlytrafficlimit_ui form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr>  
                                                                    <td><input type="radio" name="trafficlimitradio" class="form-control"></td>                           
                                                                    <td>{{ lang._("Daily") }}</td>
                                                                    <td><input id="user.dailytrafficlimit" type="text" class="trafficlimit dailytrafficlimit form-control" readonly="readonly" placeholder="Enter in Bytes"></td>
                                                                    <td><input id="user.dailytrafficlimit_ui" type="text" class="dailytrafficlimit_ui form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>        
                                                                <tr>    
                                                                    <td><input type="radio" name="trafficlimitradio" class="form-control"></td>                         
                                                                    <td>{{ lang._("Weekly") }}</td>
                                                                    <td><input id="user.weeklytrafficlimit" type="text" class="trafficlimit weeklytrafficlimit form-control" readonly="readonly" placeholder="Enter in Bytes"></td>
                                                                    <td><input id="user.weeklytrafficlimit_ui" type="text" class="weeklytrafficlimit_ui form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr>  
                                                                    <td><input type="radio" name="trafficlimitradio" class="form-control"></td>                           
                                                                    <td>{{ lang._("Monthly") }}</td>
                                                                    <td><input id="user.monthlytrafficlimit" type="text" class="trafficlimit monthlytrafficlimit form-control" readonly="readonly" placeholder="Enter in Bytes"></td>
                                                                    <td><input id="user.monthlytrafficlimit_ui" type="text" class="monthlytrafficlimit_ui form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr> 
                                                                    <td></td>                           
                                                                    <td>{{ lang._("Account") }}</td>
                                                                    <td><input id="user.accounttrafficlimit" type="text" class="accounttrafficlimit form-control" placeholder="Enter in Bytes"></td>
                                                                    <td><input id="user.accounttrafficlimit_ui" type="text" class="accounttrafficlimit_ui form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>                                                                                                                                                                                                                                                                                              
                                                            </tbody>
                                                        </table>                        
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>     
                                        <div class="hidden" data-for="help_for_user.trafficlimit">
                                            <small>
                                                {{ lang._("Set the maximum hourly, daily, weekly, monthly and account traffic limit. This can be used by the Captive Portal.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_user.trafficlimit"></span>
                                    </td>
                                </tr>                                                                   
                            </tbody>
                        </table>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{{ lang._('Close') }}</button>
                <button type="button" class="btn btn-primary" id="btn_dialogEditFreeRADIUSUser_save">{{ lang._('Save changes') }}<i id="btn_dialogEditFreeRADIUSUser_save_progress" class=""></i></button>
            </div>
        </div>
    </div>
</div>

<!-- UserGroup -->

<div class="modal fade" id="dialogEditFreeRADIUSUsergroup" tabindex="-1" role="dialog" aria-labelledby="dialogEditFreeRADIUSUsergroupLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="dialogEditFreeRADIUSUsergroupLabel">{{ lang._("Edit Usergroup") }}</h4>
            </div>
            <div class="modal-body">
                <form id="frm_dialogEditFreeRADIUSUsergroup">
                    <div class="table-responsive">
                        <table class="table table-striped table-condensed">
                            <colgroup>
                                <col class="col-md-3" />
                                <col class="col-md-6" />
                                <col class="col-md-9" />
                            </colgroup>
                            <tbody>
                                <tr>
                                    <td>
                                        <a href="#"><i class="fa fa-toggle-off text-danger" id="show_advanced_formDialogdialogEditFreeRADIUSUsergroup"></i></a>
                                        <small>{{ lang._('advanced mode') }}</small>
                                    </td>
                                    <td colspan="2" style="text-align:right;">
                                        <small>{{ lang._('full help') }}</small>
                                        <a href="#"><i class="fa fa-toggle-off text-danger" id="show_all_help_formDialogdialogEditFreeRADIUSUsergroup"></i></a>
                                    </td>
                                </tr>
                                <!-- usergroup.enabled -->
                                <tr id="row_usergroup.enabled">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.enabled">
                                            <a id="help_for_usergroup.enabled" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Enabled") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="usergroup.enabled" type="checkbox">
                                        <div class="hidden" data-for="help_for_usergroup.enabled">
                                            <small>{{ lang._("This will enable or disable the usergroup account.") }}</small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.enabled"></span>
                                    </td>
                                </tr>
                                <!-- usergroup.groupname -->
                                <tr id="row_usergroup.groupname">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.groupname">
                                            <a id="help_for_usergroup.groupname" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Group Name") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="usergroup.groupname" type="text" class="form-control">
                                        <div class="hidden" data-for="help_for_usergroup.groupname">
                                            <small>
                                                {{ lang._("Set the unique group name for the usergroup. Allowed characters are 0-9, a-z, A-Z, and ._-") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.groupname"></span>
                                    </td>
                                </tr> 
                                <!-- usergroup.description -->
                                <tr id="row_usergroup.description">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.description">
                                            <a id="help_for_usergroup.description" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Description") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="usergroup.description" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_usergroup.description">
                                            <small>
                                                {{ lang._("Given name, last name, or anything you need to describe.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.description"></span>
                                    </td>
                                </tr>  
                                <!-- usergroup.simultaneous -->
                                <tr id="row_usergroup.simultaneous">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.simultaneous">
                                            <a id="help_for_usergroup.simultaneous" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Simultaneous Use") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="usergroup.simultaneous" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_usergroup.simultaneous">
                                            <small>
                                                {{ lang._("Set the simultaneous use for the usergroup. its range from 1 to 10. if you want to remove it, leave it empty.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.simultaneous"></span>
                                    </td>
                                </tr>                                    
                                <!-- usergroup.authtype -->
                                <tr id="row_usergroup.authtype">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.authtype">
                                            <a id="help_for_usergroup.authtype" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Authentication Type") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <select id="usergroup.authtype" class="selectpicker"></select>
                                        <div class="hidden" data-for="help_for_usergroup.authtype">
                                            <small>
                                                {{ lang._("Set the authentication type of each usergroup group.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.authtype"></span>
                                    </td>
                                </tr>      
                                <!-- usergroup.replymessage -->
                                <tr id="row_usergroup.replymessage">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.replymessage">
                                            <a id="help_for_usergroup.replymessage" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Reply Message") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="usergroup.replymessage" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_usergroup.replymessage">
                                            <small>
                                                {{ lang._("Reply message return a message after authentication for usergroup group, empty message does not involved in the process.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.replymessage"></span>
                                    </td>
                                </tr>        
                                <!-- usergroup.mikrotik -->
                                <script>
                                    $( document ).ready(function() {
                                        $('#usergroup_mikrotik_box').click(function(event) {
                                            $('#usergroup_mikrotik_box').parent().hide();
                                            $('#usergroup_mikrotik_body').show();
                                        });
                                    });      
                                </script>                                   
                                <tr id="row_usergroup.mikrotik" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.mikrotik">
                                            <a id="help_for_usergroup.mikrotik" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Mikrotik VLAN") }}</b>
                                        </div>
                                    </td>
                                    <td>                                                 
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="usergroup_mikrotik_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show Mikrotik VLAN configuration") }}
                                                    </div>
                                                    <div id="usergroup_mikrotik_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("Mikrotik VLAN configuration") }}
                                                        <br/><br/>
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="usergroup_mikrotik_table"> 
                                                            <thead>
                                                                <tr>
                                                                    <th>{{ lang._("VLAN ID") }}</th>
                                                                    <th>{{ lang._("VLAN Type") }}</th>
                                                                </tr>                                      
                                                            </thead>                                                              
                                                            <tbody>                                                                       
                                                                <tr>                              
                                                                    <td>
                                                                        <input id="usergroup.mikrotik_vlan_id_number" type="text" class="form-control" >  
                                                                    </td>
                                                                    <td>    
                                                                        <input id="usergroup.mikrotik_vlan_id_type" type="text" class="form-control" >                                       
                                                                    </td>                                      
                                                                </tr>                                                                    
                                                            </tbody>
                                                        </table>                         
                                                    </div>
                                                </td>
                                            </tr>
                                        </table> 
                                        <div class="hidden" data-for="help_for_usergroup.mikrotik">
                                            <small>
                                                {{ lang._("Set the Mikrotik VLAN ID and type attribute. Mikrotik uses own attributes for VLAN assignment and for VLAN type use a value of 0 is fine.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.mikrotik"></span>
                                    </td>
                                </tr>   
                                <!-- usergroup.wispr -->
                                <!--
                                <script>
                                    $( document ).ready(function() {
                                        $('#usergroup_wispr_box').click(function(event) {
                                            $('#usergroup_wispr_box').parent().hide();
                                            $('#usergroup_wispr_body').show();
                                        });                          
                                    });      
                                </script>                                 
                                <tr id="row_usergroup.wispr" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.wispr">
                                            <a id="help_for_usergroup.wispr" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("WISPr Bandwidth") }}</b>
                                        </div>
                                    </td>
                                    <td>       
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="usergroup_wispr_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show WISPr Bandwidth configuration") }}
                                                    </div>
                                                    <div id="usergroup_wispr_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("WISPr Bandwidth configuration") }}
                                                        <br/><br/>
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="usergroup_wispr_table">                                                               
                                                            <tbody>
                                                                <tr>
                                                                    <th>{{ lang._("Minimum Upload") }}</th>
                                                                    <th>{{ lang._("Maximum Upload") }}</th>
                                                                </tr>                                                                         
                                                                <tr>                              
                                                                    <td>
                                                                        <input id="usergroup.wispr_bw_min_up" type="text" class="form-control" >  
                                                                    </td>
                                                                    <td>    
                                                                        <input id="usergroup.wispr_bw_max_up" type="text" class="form-control" >                                       
                                                                    </td>                                      
                                                                </tr>
                                                                <tr>
                                                                    <th>{{ lang._("Minimum Download") }}</th>
                                                                    <th>{{ lang._("Maximum Download") }}</th>
                                                                </tr> 
                                                                <tr>                              
                                                                    <td>
                                                                        <input id="usergroup.wispr_bw_min_down" type="text" class="form-control" >  
                                                                    </td>
                                                                    <td>    
                                                                        <input id="usergroup.wispr_bw_max_down" type="text" class="form-control" >                                       
                                                                    </td>                                      
                                                                </tr>                                                                        
                                                            </tbody>
                                                        </table>                         
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>       
                                        <div class="hidden" data-for="help_for_usergroup.wispr">
                                            <small>
                                                {{ lang._("Set the Bandwidth for WISPr attribute. The value is treated as bits/s.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.wispr"></span>
                                    </td>
                                </tr>    
                                -->
                                <!-- usergroup.chillispot -->
                                <!-- 
                                <script>
                                    $( document ).ready(function() {                        
                                        $('#usergroup_chillispot_box').click(function(event) {
                                            $('#usergroup_chillispot_box').parent().hide();
                                            $('#usergroup_chillispot_body').show();
                                        });
                                    });      
                                </script>                                    
                                <tr id="row_usergroup.chillispot" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.chillispot">
                                            <a id="help_for_usergroup.chillispot" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("ChilliSpot Bandwidth") }}</b>
                                        </div>
                                    </td>
                                    <td>      
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="usergroup_chillispot_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show ChilliSpot Bandwith configuration") }}
                                                    </div>
                                                    <div id="usergroup_chillispot_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("ChilliSpot Bandwith configuration") }}
                                                        <br/><br/>
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="usergroup_chillispot_table">   
                                                            <thead>
                                                                <tr>
                                                                    <th>{{ lang._("Maximum Upload") }}</th>
                                                                    <th>{{ lang._("Maximum Download") }}</th>
                                                                </tr>                                     
                                                            </thead>                                                            
                                                            <tbody>                                                                        
                                                                <tr>                              
                                                                    <td>
                                                                        <input id="usergroup.chillispot_bw_max_up" type="text" class="form-control" >  
                                                                    </td>
                                                                    <td>    
                                                                        <input id="usergroup.chillispot_bw_max_down" type="text" class="form-control" >                                       
                                                                    </td>                                      
                                                                </tr>                                                                    
                                                            </tbody>
                                                        </table>                         
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>   
                                        <div class="hidden" data-for="help_for_usergroup.chillispot">
                                            <small>
                                                {{ lang._("Set the Bandwidth for ChilliSpot attribute. The value is treated as kbits/s.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.chillispot"></span>
                                    </td>
                                </tr>   
                                -->
                                <!-- usergroup.logintime -->
                                <script>
                                    $(document).ready(function() {               
                                        function process_logintimte_data() {
                                            var _days = "", _start_time = "", _end_time = "", _login_time = "";
                
                                            $('#usergroup_logintimes_table > tbody  > tr').each(function() {
                                                _days = $(this).find('.days').val();
                                                _start_time = $(this).find('.start_time').val().replace(':', '');
                                                _end_time = $(this).find('.end_time').val().replace(':', '');
                
                                                if (_login_time) {
                                                    _login_time += ",";
                                                }
                
                                                if (_start_time === "" || _end_time === "") {
                                                    _login_time += _days;
                                                } else {
                                                    _login_time += _days + _start_time + '-' + _end_time;
                                                }                                
                                            });
                                            $('.logintime').val(_login_time);
                
                                            var ui_start_date = $('#usergroup_logindates_table > tbody > tr > td > .ui_start_date').val();
                                            var ui_end_date = $('#usergroup_logindates_table > tbody > tr > td > .ui_end_date').val();
                                            $('#usergroup_logindates_table > tbody > tr > td > .start_date').val(ui_start_date === "" ? "" : new Date(ui_start_date).getTime() / 1000);
                                            $('#usergroup_logindates_table > tbody > tr > td > .end_date').val(ui_end_date === "" ? "" : new Date(ui_end_date).getTime() / 1000);
                                        };
                
                                        function _fill_logintime_elements(arr) {
                                            // regex patterns
                                            var days_re = /[^-0-9]/g;
                                            var times_re = /[-0-9]/g;
                
                                            // days
                                            arr.forEach(function(element) {
                                                if (element) { 
                                                    // days
                                                    m = element.match(days_re);
                                                    if (m) {
                                                        days = m.join('');
                                                        $('#usergroup_logintimes_table > tbody').append("<tr><td><div style='cursor:pointer;' class='act-removerow btn btn-default btn-xs' alt='remove'><i class='fa fa-minus fa-fw'></i></div></td><td><select class='days {{style|default('')}}' data-width='{{width|default('120px')}}'><option value='su'>Sunday</option><option value='mo'>Monday</option><option value='tu'>Tuesday</option><option value='we'>Wednesday</option><option value='th'>Thursday</option><option value='fr'>Friday</option><option value='sa'>Saturday</option><option value='wk'>Week Days</option><option value='any'>Any Day</option><option value='al'>All Days</option></select></td><td><input type='text' class='start_time form-control' size='1px'></td><td><input type='text' class='end_time form-control' size='1px'></td></tr>");
                                                        $('#usergroup_logintimes_table > tbody > tr:last > td > .days').val(days);
                                                    }
                                                    // start_time and end_time
                                                    m = element.match(times_re);
                                                    if (m) {
                                                        times = m.join('').split('-');
                                                        times.forEach(function(part, index, theArray) {
                                                            // put ':' character to each item in array in the form of time
                                                            theArray[index] = [part.slice(0, 2), ':', part.slice(2)].join('');
                                                        });
                                                        $('#usergroup_logintimes_table > tbody > tr:last > td > .start_time').val(times[0]); //start_time
                                                        $('#usergroup_logintimes_table > tbody > tr:last > td > .end_time').val(times[1]); // end_time  
                                                    }
                                                }
                                            });
                                        }
                
                                        function fill_logintime_elements() {
                                            $('#usergroup_logintimes_table > tbody').empty();
                
                                            var usergroup_id = $(document).data('row-id');
                                            if (usergroup_id) {
                                                var _url = '/api/freeradius/usergroup/getUsergroup/' + usergroup_id;
                
                                                ajaxGet(url=_url, sendData={}, callback=function(data,status) { 
                                                    if (data === undefined && data === null) {
                                                        return;
                                                    }
                                                    if (data.usergroup.logintime_value) {
                                                        var arr = data.usergroup.logintime_value.split(',');
                                                        _fill_logintime_elements(arr);
                                                    } 
                                                    $(".act-removerow").click(removeRow); 
                                                });
                                            }
                                        }
                
                                        function removeRow() {
                                            $(this).parent().parent().remove();
                                            process_logintimte_data();
                                        }  
                
                                        $('#dialogEditFreeRADIUSUsergroup').on('shown.bs.modal', function (e) { fill_logintime_elements(); });
                                        $('#usergroup_logindates_table > tbody > tr > td > .ui_start_date').on('change', function (e) { process_logintimte_data(); });
                                        $('#usergroup_logindates_table > tbody > tr > td > .ui_end_date').on('change', function (e) { process_logintimte_data(); });
                
                                        $('#usergroup_logintimes_table > tbody').on('change', '.days', function (e) { process_logintimte_data(); });
                                        $('#usergroup_logintimes_table > tbody').on('input', '.start_time', function (e) { process_logintimte_data(); });
                                        $('#usergroup_logintimes_table > tbody').on('input', '.end_time', function (e) { process_logintimte_data(); });  
                
                                        $('#usergroup_logintime_addnew').click(function(){
                                            // copy last row and reset values
                                            $('#usergroup_logintimes_table > tbody').append("<tr><td><div style='cursor:pointer;' class='act-removerow btn btn-default btn-xs' alt='remove'><i class='fa fa-minus fa-fw'></i></div></td><td><select class='days' data-width='120px'><option value='su'>Sunday</option><option value='mo'>Monday</option><option value='tu'>Tuesday</option><option value='we'>Wednesday</option><option value='th'>Thursday</option><option value='fr'>Friday</option><option value='sa'>Saturday</option><option value='wk'>Week Days</option><option value='any'>Any Day</option><option value='al'>All Days</option></select></td><td><input type='text' class='start_time form-control' size='1px'></td><td><input type='text' class='end_time form-control' size='1px'></td></tr>");
                                            $(".act-removerow").click(removeRow);
                                            process_logintimte_data();
                                        });

                                        $('#usergroup_logintime_box').click(function(event) {
                                            $('#usergroup_logintime_box').parent().hide();
                                            $('#usergroup_logintime_body').show();
                                        });                                        
                                    });      
                                </script>                                    
                                <tr id="row_usergroup.logintime" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.logintime">
                                            <a id="help_for_usergroup.logintime" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Login Time") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="usergroup_logintime_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show login time configuration") }}
                                                    </div>
                                                    <div id="usergroup_logintime_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("Login Time configuration") }}
                                                        <br/><br/>
                                                        <input type="text" id="usergroup.logintime_value" class="logintime hidden form-control" readonly="readonly">
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="usergroup_logindates_table">  
                                                            <thead>
                                                                <tr>
                                                                    <th>{{ lang._("Start Date") }}</th>
                                                                    <th>{{ lang._("End Date") }}</th>
                                                                </tr>
                                                            </thead>    
                                                            <tbody>                                                                          
                                                                <tr>                              
                                                                    <td>    
                                                                        <input id="usergroup.logintime_ui_start_date" type="text" class="ui_start_date form-control" placeholder="YYYY/MM/dd"> 
                                                                        <input id="usergroup.logintime_start_date" type="text" class="start_date hidden form-control" >                                       
                                                                    </td>
                                                                    <td>
                                                                        <input id="usergroup.logintime_ui_end_date" type="text" class="ui_end_date form-control" placeholder="YYYY/MM/dd">
                                                                        <input id="usergroup.logintime_end_date" type="text" class="end_date hidden form-control" >
                                                                    </td>
                                                                </tr>
                                                            </tbody>                                                            
                                                        </table>  
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="usergroup_logintimes_table">      
                                                            <thead>
                                                                <tr>
                                                                    <th></th>
                                                                    <th>{{ lang._("Days") }}</th>
                                                                    <th>{{ lang._("From") }}</th>
                                                                    <th>{{ lang._("To") }}</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>                                                                          
                                                            </tbody>
                                                            <tfoot>
                                                                <tr>
                                                                    <td colspan="4">
                                                                        <div id="usergroup_logintime_addnew" style="cursor:pointer;" class="btn btn-default btn-xs" alt="add"><i class="fa fa-plus fa-fw"></i></div>
                                                                    </td>
                                                                </tr>
                                                            </tfoot>
                                                        </table>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                        <div class="hidden" data-for="help_for_usergroup.logintime">
                                            <small>
                                                {{ lang._("Set the Login-Time. This can be used by the Captive Portal.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.logintime"></span>
                                    </td>
                                </tr>  
                                <!-- usergroup.bandwidthlimit -->
                                <tr id="row_usergroup.bandwidthlimit" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.bandwidthlimit">
                                            <a id="help_for_usergroup.bandwidthlimit" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Max Bandwidth Limit") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <select id="usergroup.bandwidthlimit" class="selectpicker"></select>
                                        <div class="hidden" data-for="help_for_usergroup.bandwidthlimit">
                                            <small>
                                                {{ lang._("Set the bandwidth limit of each user group.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.bandwidthlimit"></span>
                                    </td>
                                </tr>                                   
                                <!-- usergroup.sessionlimit -->
                                <script>
                                    $( document ).ready(function() {                
                                        function process_sessionlimit_data(element) {
                                            var _sessionlimit = $("#usergroup_sessionlimit_table > tbody > tr").find(element).val();
                                            if (_sessionlimit) {
                                                var isValid = false;
                                                var type = element.replace('.', '').replace('sessionlimit_ui', '');
                                                if (type === 'hourly') {
                                                    isValid = (_sessionlimit.search(/^\d{2}:\d{2}:\d{2}$/) !== -1) &&
                                                        (_sessionlimit.substr(0,2) >= 0 && _sessionlimit.substr(0,2) <= 0) &&
                                                        (_sessionlimit.substr(3,2) >= 0 && _sessionlimit.substr(3,2) <= 59) &&
                                                        (_sessionlimit.substr(6,2) >= 0 && _sessionlimit.substr(6,2) <= 59);
                                                } else if (type === 'daily') {
                                                    isValid = (_sessionlimit.search(/^\d{2}:\d{2}:\d{2}$/) !== -1) &&
                                                        (_sessionlimit.substr(0,2) >= 0 && _sessionlimit.substr(0,2) <= 24) &&
                                                        (_sessionlimit.substr(3,2) >= 0 && _sessionlimit.substr(3,2) <= 59) &&
                                                        (_sessionlimit.substr(6,2) >= 0 && _sessionlimit.substr(6,2) <= 59);
                                                } else if (type === 'weekly' || type === 'monthly' || type === 'account') {
                                                    var max = 0;
                                                    if (type === 'weekly') {
                                                        max = 168;  // 7 * 24
                                                    } else if (type === 'monthly') {
                                                        max = 720; // 30 * 24
                                                    } else if (type === 'account') { 
                                                        max = 8760; // 365 * 24
                                                    }
                                                    var doubleDigit = (_sessionlimit.search(/^\d{2}:\d{2}:\d{2}$/) !== -1); 
                                                    var tripleDigit = (_sessionlimit.search(/^\d{3}:\d{2}:\d{2}$/) !== -1); 
                                                    var quadrupleDigit = (_sessionlimit.search(/^\d{4}:\d{2}:\d{2}$/) !== -1); 
                                                    if (doubleDigit) {
                                                        isValid = (_sessionlimit.substr(0,2) >= 0 && _sessionlimit.substr(0,2) <= max) &&
                                                            (_sessionlimit.substr(3,2) >= 0 && _sessionlimit.substr(3,2) <= 59) &&
                                                            (_sessionlimit.substr(6,2) >= 0 && _sessionlimit.substr(6,2) <= 59);
                                                    } else if (tripleDigit) {
                                                        isValid = (_sessionlimit.substr(0,3) >= 0 && _sessionlimit.substr(0,3) <= max) &&
                                                            (_sessionlimit.substr(4,2) >= 0 && _sessionlimit.substr(4,2) <= 59) &&
                                                            (_sessionlimit.substr(7,2) >= 0 && _sessionlimit.substr(7,2) <= 59);
                                                    } else if (quadrupleDigit && type === 'account') {
                                                        isValid = (_sessionlimit.substr(0,4) >= 0 && _sessionlimit.substr(0,4) <= max) &&
                                                            (_sessionlimit.substr(5,2) >= 0 && _sessionlimit.substr(5,2) <= 59) &&
                                                            (_sessionlimit.substr(8,2) >= 0 && _sessionlimit.substr(8,2) <= 59);
                                                    }
                                                } 
                                                if (isValid) {
                                                    var a = _sessionlimit.split(':');
                                                    _sessionlimit = (+a[0]) * 60 * 60 + (+a[1]) * 60 + (+a[2]); 
                                                    _sessionlimit = _sessionlimit <= 0 ? "" : _sessionlimit.toString();
                                                } else {
                                                    _sessionlimit = '';
                                                }
                                            }
                                            $("#usergroup_sessionlimit_table > tbody > tr > td").find(element.replace('_ui', '')).val(_sessionlimit);
                                        };
                
                                        $('#dialogEditFreeRADIUSUsergroup').on('shown.bs.modal', function (e) { 
                                            process_sessionlimit_data('.hourlysessionlimit_ui');
                                            process_sessionlimit_data('.dailysessionlimit_ui');
                                            process_sessionlimit_data('.weeklysessionlimit_ui');
                                            process_sessionlimit_data('.monthlysessionlimit_ui');
                                            process_sessionlimit_data('.accountsessionlimit_ui'); 
                                        });

                                        $("#usergroup_sessionlimit_table > tbody > tr").on('input', '.hourlysessionlimit_ui', function (e) { process_sessionlimit_data('.hourlysessionlimit_ui'); });
                                        $("#usergroup_sessionlimit_table > tbody > tr").on('input', '.dailysessionlimit_ui', function (e) { process_sessionlimit_data('.dailysessionlimit_ui'); });
                                        $("#usergroup_sessionlimit_table > tbody > tr").on('input', '.weeklysessionlimit_ui', function (e) { process_sessionlimit_data('.weeklysessionlimit_ui'); });
                                        $("#usergroup_sessionlimit_table > tbody > tr").on('input', '.monthlysessionlimit_ui', function (e) { process_sessionlimit_data('.monthlysessionlimit_ui'); });
                                        $("#usergroup_sessionlimit_table > tbody > tr").on('input', '.accountsessionlimit_ui', function (e) { process_sessionlimit_data('.accountsessionlimit_ui'); });

                                        $("#usergroup_sessionlimit_table > tbody > tr > td > input[name='sessionlimitradio']").on('change', function (e) {
                                            if($(this).is(':checked')) {
                                                $("#usergroup_sessionlimit_table > tbody > tr > td > input[type='text']").val('');
                                                $("#usergroup_sessionlimit_table > tbody > tr > td > input.sessionlimit_ui").attr('readonly', false);
                                                $("#usergroup_sessionlimit_table > tbody > tr > td > input.sessionlimit_ui").not($(this).parent().nextAll().children('input.sessionlimit_ui')).attr('readonly', true);
                                            }
                                         });                                        

                                        $('#usergroup_sessionlimit_box').click(function(event) {
                                            $('#usergroup_sessionlimit_box').parent().hide();
                                            $('#usergroup_sessionlimit_body').show();
                                        });                                         
                                    });      
                                </script>                                  
                                <tr id="row_usergroup.sessionlimit" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.sessionlimit">
                                            <a id="help_for_usergroup.sessionlimit" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Max Session Limit") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="usergroup_sessionlimit_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show max  session limit configuration") }}
                                                    </div>
                                                    <div id="usergroup_sessionlimit_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("Max session limit configuration") }}
                                                        <br/><br/>
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="usergroup_sessionlimit_table">                                                                                          
                                                            <tbody>                                                                          
                                                                <tr>    
                                                                    <td><input type="radio" name="sessionlimitradio" class="form-control" checked></td>                        
                                                                    <td>{{ lang._("Hourly") }}</td>
                                                                    <td><input id="usergroup.hourlysessionlimit_ui" type="text" class="sessionlimit_ui hourlysessionlimit_ui form-control" placeholder="00:mm:ss"></td>
                                                                    <td><input id="usergroup.hourlysessionlimit" type="text" class="hourlysessionlimit form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr>   
                                                                    <td><input type="radio" name="sessionlimitradio" class="form-control"></td>                        
                                                                    <td>{{ lang._("Daily") }}</td>
                                                                    <td><input id="usergroup.dailysessionlimit_ui" type="text" class="sessionlimit_ui dailysessionlimit_ui form-control" readonly="readonly" placeholder="HH:mm:ss"></td>
                                                                    <td><input id="usergroup.dailysessionlimit" type="text" class="dailysessionlimit form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>        
                                                                <tr>                          
                                                                    <td><input type="radio" name="sessionlimitradio" class="form-control"></td>  
                                                                    <td>{{ lang._("Weekly") }}</td>
                                                                    <td><input id="usergroup.weeklysessionlimit_ui" type="text" class="sessionlimit_ui weeklysessionlimit_ui form-control" readonly="readonly" placeholder="[HH, HHH]:mm:ss"></td>
                                                                    <td><input id="usergroup.weeklysessionlimit" type="text" class="weeklysessionlimit form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr>        
                                                                    <td><input type="radio" name="sessionlimitradio" class="form-control"></td>                    
                                                                    <td>{{ lang._("Monthly") }}</td>
                                                                    <td><input id="usergroup.monthlysessionlimit_ui" type="text" class="sessionlimit_ui monthlysessionlimit_ui form-control" readonly="readonly" placeholder="[HH, HHH]:mm:ss"></td>
                                                                    <td><input id="usergroup.monthlysessionlimit" type="text" class="monthlysessionlimit form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr>  
                                                                    <td></td>                          
                                                                    <td>{{ lang._("Account") }}</td>
                                                                    <td><input id="usergroup.accountsessionlimit_ui" type="text" class="accountsessionlimit_ui form-control" placeholder="[HH, HHH, HHHH]:mm:ss"></td>
                                                                    <td><input id="usergroup.accountsessionlimit" type="text" class="accountsessionlimit form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>                                                                                                                                                                                                                                                                                              
                                                            </tbody>
                                                        </table>                        
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>     
                                        <div class="hidden" data-for="help_for_usergroup.sessionlimit">
                                            <small>
                                                {{ lang._("Set the maximum hourly, daily, weekly, monthly and account session limit. This can be used by the Captive Portal.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.sessionlimit"></span>
                                    </td>
                                </tr>                                 
                                <!-- usergroup.trafficlimit -->
                                <script>
                                    $( document ).ready(function() {   
                                        function formatBytes(bytes, decimals) {
                                            var k = 1024, dm = decimals <= 0 ? 0 : decimals || 2,
                                                sizes = ['Bytes', 'KBytes', 'MBytes', 'GBytes', 'TBytes', 'PBytes', 'EBytes', 'ZBytes', 'YBytes'],
                                                i = Math.floor(Math.log(bytes) / Math.log(k));
                                            return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
                                        }

                                        function process_trafficlimit_data(element) {
                                            var _trafficlimit = $("#usergroup_trafficlimit_table > tbody > tr").find(element).val();
                                            if (_trafficlimit.search(/^\d+$/) !== -1) {
                                                _trafficlimit = Number(_trafficlimit) <= 0 ? "" : formatBytes(Number(_trafficlimit), 4);
                                            } else {
                                                _trafficlimit = '';
                                            }
                                            $("#usergroup_trafficlimit_table > tbody > tr > td").find(element + '_ui').val(_trafficlimit);
                                        };
                
                                        $('#dialogEditFreeRADIUSUsergroup').on('shown.bs.modal', function (e) { 
                                            process_trafficlimit_data('.hourlytrafficlimit');
                                            process_trafficlimit_data('.dailytrafficlimit');
                                            process_trafficlimit_data('.weeklytrafficlimit');
                                            process_trafficlimit_data('.monthlytrafficlimit');
                                            process_trafficlimit_data('.accounttrafficlimit'); 
                                        });

                                        $("#usergroup_trafficlimit_table > tbody > tr").on('input', '.hourlytrafficlimit', function (e) { process_trafficlimit_data('.hourlytrafficlimit'); });
                                        $("#usergroup_trafficlimit_table > tbody > tr").on('input', '.dailytrafficlimit', function (e) { process_trafficlimit_data('.dailytrafficlimit'); });
                                        $("#usergroup_trafficlimit_table > tbody > tr").on('input', '.weeklytrafficlimit', function (e) { process_trafficlimit_data('.weeklytrafficlimit'); });
                                        $("#usergroup_trafficlimit_table > tbody > tr").on('input', '.monthlytrafficlimit', function (e) { process_trafficlimit_data('.monthlytrafficlimit'); });
                                        $("#usergroup_trafficlimit_table > tbody > tr").on('input', '.accounttrafficlimit', function (e) { process_trafficlimit_data('.accounttrafficlimit'); });

                                        $("#usergroup_trafficlimit_table > tbody > tr > td > input[name='trafficlimitradio']").on('change', function (e) {
                                            if($(this).is(':checked')) {
                                                $("#usergroup_trafficlimit_table > tbody > tr > td > input[type='text']").val('');
                                                $("#usergroup_trafficlimit_table > tbody > tr > td > input.trafficlimit").attr('readonly', false);
                                                $("#usergroup_trafficlimit_table > tbody > tr > td > input.trafficlimit").not($(this).parent().nextAll().children('input.trafficlimit')).attr('readonly', true);
                                            }
                                         });                                          

                                        $('#usergroup_trafficlimit_box').click(function(event) {
                                            $('#usergroup_trafficlimit_box').parent().hide();
                                            $('#usergroup_trafficlimit_body').show();
                                        });                                         
                                    });      
                                </script>                                  
                                <tr id="row_usergroup.trafficlimit" data-advanced="true">
                                    <td>
                                        <div class="control-label" id="control_label_usergroup.trafficlimit">
                                            <a id="help_for_usergroup.trafficlimit" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Max Traffic Limit") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <table class="opnsense_standard_table_form">
                                            <tr>
                                                <td>
                                                    <div>
                                                        <input id="usergroup_trafficlimit_box" type="button" class="btn btn-default btn-xs" value="{{ lang._('Advanced') }}" /> - {{ lang._("Show max  traffic limit configuration") }}
                                                    </div>
                                                    <div id="usergroup_trafficlimit_body" style="display: none;" class="table-responsive">
                                                        {{ lang._("Max traffic limit configuration") }}
                                                        <br/><br/>
                                                        <table class="table table-striped table-condensed opnsense_standard_table_form" id="usergroup_trafficlimit_table">                                                                                          
                                                            <tbody>                                                                          
                                                                <tr> 
                                                                    <td><input type="radio" name="trafficlimitradio" class="form-control" checked></td>                           
                                                                    <td>{{ lang._("Hourly") }}</td>
                                                                    <td><input id="usergroup.hourlytrafficlimit" type="text" class="trafficlimit hourlytrafficlimit form-control" placeholder="Enter in Bytes"></td>
                                                                    <td><input id="usergroup.hourlytrafficlimit_ui" type="text" class="hourlytrafficlimit_ui form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr> 
                                                                    <td><input type="radio" name="trafficlimitradio" class="form-control"></td>                           
                                                                    <td>{{ lang._("Daily") }}</td>
                                                                    <td><input id="usergroup.dailytrafficlimit" type="text" class="trafficlimit dailytrafficlimit form-control" readonly="readonly" placeholder="Enter in Bytes"></td>
                                                                    <td><input id="usergroup.dailytrafficlimit_ui" type="text" class="dailytrafficlimit_ui form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>        
                                                                <tr>              
                                                                    <td><input type="radio" name="trafficlimitradio" class="form-control"></td>                
                                                                    <td>{{ lang._("Weekly") }}</td>
                                                                    <td><input id="usergroup.weeklytrafficlimit" type="text" class="trafficlimit weeklytrafficlimit form-control" readonly="readonly" placeholder="Enter in Bytes"></td>
                                                                    <td><input id="usergroup.weeklytrafficlimit_ui" type="text" class="weeklytrafficlimit_ui form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr>                  
                                                                    <td><input type="radio" name="trafficlimitradio" class="form-control"></td>            
                                                                    <td>{{ lang._("Monthly") }}</td>
                                                                    <td><input id="usergroup.monthlytrafficlimit" type="text" class="trafficlimit monthlytrafficlimit form-control" readonly="readonly" placeholder="Enter in Bytes"></td>
                                                                    <td><input id="usergroup.monthlytrafficlimit_ui" type="text" class="monthlytrafficlimit_ui form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>  
                                                                <tr>   
                                                                    <td></td>                         
                                                                    <td>{{ lang._("Account") }}</td>
                                                                    <td><input id="usergroup.accounttrafficlimit" type="text" class="accounttrafficlimit form-control" placeholder="Enter in Bytes"></td>
                                                                    <td><input id="usergroup.accounttrafficlimit_ui" type="text" class="accounttrafficlimit_ui form-control" size="13" readonly="readonly"></td>                                          
                                                                </tr>                                                                                                                                                                                                                                                                                              
                                                            </tbody>
                                                        </table>                        
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>     
                                        <div class="hidden" data-for="help_for_usergroup.trafficlimit">
                                            <small>
                                                {{ lang._("Set the maximum hourly, daily, weekly, monthly and account traffic limit. This can be used by the Captive Portal.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_usergroup.trafficlimit"></span>
                                    </td>
                                </tr>                                                                     
                            </tbody>
                        </table>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{{ lang._('Close') }}</button>
                <button type="button" class="btn btn-primary" id="btn_dialogEditFreeRADIUSUsergroup_save">{{ lang._('Save changes') }}<i id="btn_dialogEditFreeRADIUSUsergroup_save_progress" class=""></i></button>
            </div>
        </div>
    </div>
</div>


<!-- Bandwidthrule-->
<div class="modal fade" id="dialogEditFreeRADIUSBandwidthrule" tabindex="-1" role="dialog" aria-labelledby="dialogEditFreeRADIUSBandwidthruleLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="dialogEditFreeRADIUSBandwidthruleLabel">{{ lang._("Edit Bandwidth Rule") }}</h4>
            </div>
            <div class="modal-body">
                <form id="frm_dialogEditFreeRADIUSBandwidthrule">
                    <div class="table-responsive">
                        <table class="table table-striped table-condensed">
                            <colgroup>
                                <col class="col-md-3" />
                                <col class="col-md-6" />
                                <col class="col-md-6" />
                            </colgroup>
                            <tbody>
                                <tr>
                                    <td>
                                        <a href="#"><i class="fa fa-toggle-off text-danger" id="show_advanced_dialogEditFreeRADIUSBandwidthrule"></i></a>
                                        <small>{{ lang._('advanced mode') }}</small>
                                    </td>
                                    <td colspan="2" style="text-align:right;">
                                        <small>{{ lang._('full help') }}</small>
                                        <a href="#"><i class="fa fa-toggle-off text-danger" id="show_all_help_dialogEditFreeRADIUSBandwidthrule"></i></a>
                                    </td>
                                </tr>
                                <!-- bandwidthrule.enabled -->
                                <tr id="row_bandwidthrule.enabled">
                                    <td>
                                        <div class="control-label" id="control_label_bandwidthrule.enabled">
                                            <a id="help_for_bandwidthrule.enabled" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Enabled") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="bandwidthrule.enabled" type="checkbox">
                                        <div class="hidden" data-for="help_for_bandwidthrule.enabled">
                                            <small>{{ lang._("This will enable or disable the bandwidth rules.") }}</small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_bandwidthrule.enabled"></span>
                                    </td>
                                </tr> 
                                <!-- bandwidthrule.uploadbandwidth -->
                                <tr id="row_bandwidthrule.uploadbandwidth">
                                    <td>
                                        <div class="control-label" id="control_label_bandwidthrule.uploadbandwidth">
                                            <a id="help_for_bandwidthrule.uploadbandwidth" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Upload Bandwidth") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="bandwidthrule.uploadbandwidth" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_bandwidthrule.uploadbandwidth">
                                            <small>
                                                {{ lang._("Total upload bandwidth for this rule") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_bandwidthrule.uploadbandwidth"></span>
                                    </td>
                                </tr>        
                                <!-- bandwidthrule.uploadmetric -->
                                <tr id="row_bandwidthrule.uploadmetric">
                                    <td>
                                        <div class="control-label" id="control_label_bandwidthrule.uploadmetric">
                                            <a id="help_for_bandwidthrule.uploadmetric" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Bandwidth Metric") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <select id="bandwidthrule.uploadmetric" class="selectpicker"></select>
                                        <div class="hidden" data-for="help_for_bandwidthrule.uploadmetric">
                                            <small>
                                                {{ lang._("Set the upload bandwidth metric for this rule.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_bandwidthrule.uploadmetric"></span>
                                    </td>
                                </tr>   

                                <!-- bandwidthrule.downloadbandwidth -->
                                <tr id="row_bandwidthrule.downloadbandwidth">
                                    <td>
                                        <div class="control-label" id="control_label_bandwidthrule.downloadbandwidth">
                                            <a id="help_for_bandwidthrule.downloadbandwidth" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Download Bandwidth") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="bandwidthrule.downloadbandwidth" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_bandwidthrule.downloadbandwidth">
                                            <small>
                                                {{ lang._("Total download bandwidth for this rule") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_bandwidthrule.downloadbandwidth"></span>
                                    </td>
                                </tr>        
                                <!-- bandwidthrule.downloadmetric -->
                                <tr id="row_bandwidthrule.downloadmetric">
                                    <td>
                                        <div class="control-label" id="control_label_bandwidthrule.downloadmetric">
                                            <a id="help_for_bandwidthrule.downloadmetric" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Bandwidth Metric") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <select id="bandwidthrule.downloadmetric" class="selectpicker"></select>
                                        <div class="hidden" data-for="help_for_bandwidthrule.downloadmetric">
                                            <small>
                                                {{ lang._("Set the download bandwidth metric for this rule.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_bandwidthrule.downloadmetric"></span>
                                    </td>
                                </tr>                                   
                                <!-- bandwidthrule.description -->
                                <tr id="row_bandwidthrule.description">
                                    <td>
                                        <div class="control-label" id="control_label_bandwidthrule.description">
                                            <a id="help_for_bandwidthrule.description" href="#" class="showhelp"><i class="fa fa-info-circle"></i></a>
                                            <b>{{ lang._("Description") }}</b>
                                        </div>
                                    </td>
                                    <td>
                                        <input id="bandwidthrule.description" type="text" class="form-control" >
                                        <div class="hidden" data-for="help_for_bandwidthrule.description">
                                            <small>
                                                {{ lang._("Given name that you need to describe bandwidth rule.") }}
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="help-block" id="help_block_bandwidthrule.description"></span>
                                    </td>
                                </tr>                                                                                                                          
                            </tbody>
                        </table>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{{ lang._('Close') }}</button>
                <button type="button" class="btn btn-primary" id="btn_dialogEditFreeRADIUSBandwidthrule_save">{{ lang._('Save changes') }}<i id="btn_dialogEditFreeRADIUSBandwidthrule_save_progress" class=""></i></button>
            </div>
        </div>
    </div>
</div>                                
    