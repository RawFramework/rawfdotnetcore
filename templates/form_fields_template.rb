@form_fields = {}
@form_fields[:select_from] = "
                    <div class='form-group'>
                        <label class='col-sm-2 control-label'>%s</label>
                        <div class='col-sm-4 selectContainer'>
                            <select name='%s' class='form-control' 
                            data-bind='options: %s, 
                            optionsCaption: \"Choose one...\" , 
                            optionsText: function(item){return item.%s},
                            optionsValue: function(item){return item.%s},
                            value: %s'>
                            </select>
                        </div>
                    </div>
                    "
@form_fields[:text] = "
                    <div class='form-group'>
                        <label class='col-sm-2 control-label'>%s</label>
                        <div class='col-sm-4'>
                            <input type='text' class='form-control' name='%s' %s/>
                        </div>
                    </div>
                    "
@form_fields[:hidden] = "
                    <div class='form-group'>
                        <div class='col-sm-4'>
                            <input type='text' name='%s' %s hidden/>
                        </div>
                    </div>
                    "
@form_fields[:button] = "
                    <div class='form-group'>
                        <label class='col-sm-2 control-label'>%s</label>
                        <div class='col-sm-4'>
                            <a %s name='%s' class='btn btn-default'>Edit</a>
                        </div>
                    </div>
                    "
@form_fields[:datepicker] = "
                    <div class='form-group'>
                        <label class='col-sm-2 control-label'>%s</label>
                        <div class='col-sm-4'>
                            <div class='input-group date' id='%s'>
                                <input type='text' class='form-control' name='%s' data-bind='datetimepicker: $parent.dateSelected'/>
                                <span class='input-group-addon'>
                                    <span class='glyphicon glyphicon-calendar'></span>
                                </span>
                            </div>
                        </div>
                    </div>
                    "
@form_fields[:checkbox] = "
                    <div class='form-group'>
                        <label class='col-sm-2 control-label'>%s</label>
                        <div class='col-sm-4'>
                            <input type='checkbox'  name='%s' %s/>
                        </div>
                    </div>
                    "
@form_fields[:autocomplete] = "
                    <div class='form-group'>
                        <label class='col-sm-2 control-label'>%s</label>
                        <div class='col-sm-4'>
                            <input type='hidden' name='%s' %s/>
                            <input type='text' name='%s' class='form-control autocomplete' 
                            searchfield='%s' idfield='%s' showfield='%s' order='%s' referencedtable='%s'
                            />
                        </div>
                    </div>
                    "

