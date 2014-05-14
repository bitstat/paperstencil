var FB = {
    // different type of fields
    fieldTypes: [],
    fieldTypesHash: {},
    lastConfiguredField: null,
    currMorphRef: null,

    findFieldType: function (type) {
        return this.fieldTypesHash[type]
    },

    defaultFieldType: function () {
        return this.fieldTypes[0];
    },

    fieldTypeBase: {
        constructWidget: function () {
            return $('<option/>')
                .attr("value", this.type)
                .text(this.widgetName);
        },

        constructField: function (properties) {
            var data = $.extend({}, this.default_value, properties);
            if (data.id === undefined || data.id === null) {
                data.id = $().unique();
            }
            data.type = this.type;
            var field = new FB.Field($.tmpl(this.template, data));
            field.settings = this.settings(field);
            return field;
        }
    },

    fieldTypeBuilder: function (fieldType) {
        var fType = $.extend(fieldType, this.fieldTypeBase)
        this.fieldTypesHash[fieldType.type] = fType
        this.fieldTypes.push(fType);
    },

    populate: function (data) {
        if ($.isArray(data.fields)) {
            $.each(function (i, fieldData) {
                var fieldType = FB.findFieldType(fieldData.type);
                FB.createAndShowField(fieldType, fieldData.pos, fieldData);
            });
        }
    },

    // field settings constructs
    fieldSettings: {

        _numberUpdater: function (field, value) {
            return function () {
                var data = field.data();
                var integer = parseInt($(this).val(), 10);
                if (isNaN(integer)) {
                    integer = null;
                    data[value] = null;
                } else {
                    data[value] = integer.toString();
                }

                $(this).val(integer);
                field.update(data);
            };
        },
        _selectUpdate: function (field, value) {
            return function () {
                var data = field.data();
                data[value] = $(this).find("option:selected").val();
                field.update(data);
            };
        },

        _checkUpdate: function (field, value) {
            return function () {
                var data = field.data();
                data[value] = $(this).is(':checked');
                field.update(data);
            };
        },

        _valUpdate: function (field, value) {
            return function () {
                var data = field.data();
                data[value] = $(this).val();
                field.update(data);
            };
        },

        label : function(field, value) {
            var textarea = $('<textarea rows="2" columns="35" class="form-control" />')
                .html(field.data()[value]);

            textarea.keyup(this._valUpdate(field, value));

            return $('<div class="form-group"><label class="control-label col-xs-3 col-sm-3 col-xs-3 col-sm-3 col-md-3">Field label</label></div>')
                .append($('<div class="col-xs-5 col-sm-5 col-md-5"></div>')
                    .append(textarea));
        },

        predefined_value: function (field, value) {
            var textfield = $('<input type="text" class="form-control"/>')
                .val(field.data()[value]);
            textfield.keyup(this._valUpdate(field, value));

            return $('<div class="form-group"><label class="control-label col-xs-3 col-sm-3 col-md-3">Preset Value</label></div>')
                .append($('<div class="col-xs-5 col-sm-5 col-md-5">')
                    .append(textfield));
        },

        _select_field: function (field, value, label_text, options, optgroup) {

            var selectField = $('<select class="form-control">');

            if (optgroup) {
                // default
                selectField.append($('<option>').val(field.data()[value]).html(field.data()[value]));

                $.each(options, function (group, values) {
                    var optgroupField = $('<optgroup>');
                    optgroupField.attr('label', group);
                    $.each(values, function (i, value) {
                        optgroupField.append($('<option>').val(value).html(value));
                    });
                    selectField.append(optgroupField);
                });
            } else {
                $.each(options, function () {
                    selectField.append($('<option>')
                        .val(this.val)
                        .html(this.text));
                });
            }

            selectField.val(field.data()[value]);
            selectField.change(this._selectUpdate(field, value));

            return $('<div class="form-group"></div>')
                .append($('<label class="control-label col-xs-3 col-sm-3 col-md-3">').html(label_text))
                .append($('<div class="col-xs-5 col-sm-5 col-md-5">')
                    .append(selectField));
        },

        field_size: function (field, value) {

            var options = $.map(['small', 'medium', 'large'], function (value) {
                return { val: value, text: value.capitalize() };
            });

            return this._select_field(field, value, "Field Size", options);
        },


        field_layout: function (field, value) {
            var options = $.map(['one_column', 'two_columns', 'three_columns', 'side_by_side'], function (value) {
                return {
                    val: value,
                    text: $.map(value.split('_'),
                        function (x) {
                            return x.capitalize();
                        }).join(' ')
                };
            });

            return this._select_field(field, value, "Field Layout", options);
        },

        name_format: function (field, value) {
            var options = $.map(['normal', 'extended'], function (value) {
                return { val: value, text: value.capitalize() };
            });

            return this._select_field(field, value, "Name Format", options);
        },

        date_format: function (field, value) {
            var options = $.map(['mm/dd/yyyy', 'dd/mm/yyyy'], function (value) {
                return { val: value, text: value.toUpperCase() };
            });

            return this._select_field(field, value, "Date Format", options);
        },

        phone_format: function (field, value) {
            var options = [
                { val: "international", text: "International" },
                { val: "other", text: "###-###-###" }
            ];
            return this._select_field(field, value, "Phone Format", options);
        },

        country_options: function (field, value) {
            var countries = {
                "North America": [
                    "Antigua and Barbuda",
                    "Aruba",
                    "Bahamas",
                    "Barbados",
                    "Belize",
                    "Bermuda",
                    "Canada",
                    "Cayman Islands",
                    "Cook Islands",
                    "Costa Rica",
                    "Cuba",
                    "Dominica",
                    "Dominican Republic",
                    "El Salvador",
                    "Grenada",
                    "Guatemala",
                    "Haiti",
                    "Honduras",
                    "Jamaica",
                    "Mexico",
                    "Netherlands Antilles",
                    "Nicaragua",
                    "Panama",
                    "Puerto Rico",
                    "Saint Kitts and Nevis",
                    "Saint Lucia",
                    "Saint Vincent and the Grenadines",
                    "Trinidad and Tobago",
                    "United States",
                    "Virgin Islands, British",
                    "Virgin Islands, U.S."
                ],

                "South America": [
                    "Argentina",
                    "Bolivia",
                    "Brazil",
                    "Chile",
                    "Colombia",
                    "Ecuador",
                    "Guyana",
                    "Paraguay",
                    "Peru",
                    "Suriname",
                    "Uruguay",
                    "Venezuela"
                ],

                "Europe": [
                    "Albania",
                    "Andorra",
                    "Armenia",
                    "Austria",
                    "Azerbaijan",
                    "Belarus",
                    "Belgium",
                    "Bosnia and Herzegovina",
                    "Bulgaria",
                    "Croatia",
                    "Cyprus",
                    "Czech Republic",
                    "Denmark",
                    "Estonia",
                    "Faroe Islands",
                    "Finland",
                    "France",
                    "Georgia",
                    "Germany",
                    "Greece",
                    "Hungary",
                    "Iceland",
                    "Ireland",
                    "Italy",
                    "Latvia",
                    "Liechtenstein",
                    "Lithuania",
                    "Luxembourg",
                    "Macedonia",
                    "Malta",
                    "Moldova",
                    "Monaco",
                    "Montenegro",
                    "Netherlands",
                    "Norway",
                    "Poland",
                    "Portugal",
                    "Romania",
                    "San Marino",
                    "Serbia",
                    "Slovakia",
                    "Slovenia",
                    "Spain",
                    "Sweden",
                    "Switzerland",
                    "Ukraine",
                    "United Kingdom",
                    "Vatican City"
                ],

                "Asia": [
                    "Afghanistan",
                    "Bahrain",
                    "Bangladesh",
                    "Bhutan",
                    "Brunei Darussalam",
                    "Myanmar",
                    "Cambodia",
                    "China",
                    "East Timor",
                    "Hong Kong",
                    "India",
                    "Indonesia",
                    "Iran",
                    "Iraq",
                    "Israel",
                    "Japan",
                    "Jordan",
                    "Kazakhstan",
                    "North Korea",
                    "South Korea",
                    "Kuwait",
                    "Kyrgyzstan",
                    "Laos",
                    "Lebanon",
                    "Malaysia",
                    "Maldives",
                    "Mongolia",
                    "Nepal",
                    "Oman",
                    "Pakistan",
                    "Palestine",
                    "Philippines",
                    "Qatar",
                    "Russia",
                    "Saudi Arabia",
                    "Singapore",
                    "Sri Lanka",
                    "Syria",
                    "Taiwan",
                    "Tajikistan",
                    "Thailand",
                    "Turkey",
                    "Turkmenistan",
                    "United Arab Emirates",
                    "Uzbekistan",
                    "Vietnam",
                    "Yemen"
                ],

                "Oceania": [
                    "Australia",
                    "Fiji",
                    "Kiribati",
                    "Marshall Islands",
                    "Micronesia",
                    "Nauru",
                    "New Zealand",
                    "Palau",
                    "Papua New Guinea",
                    "Samoa",
                    "Solomon Islands",
                    "Tonga",
                    "Tuvalu",
                    "Vanuatu"
                ],

                "Africa": [
                    "Algeria",
                    "Angola",
                    "Benin",
                    "Botswana",
                    "Burkina Faso",
                    "Burundi",
                    "Cameroon",
                    "Cape Verde",
                    "Central African Republic",
                    "Chad",
                    "Comoros",
                    "Democratic Republic of the Congo",
                    "Republic of the Congo",
                    "Djibouti",
                    "Egypt",
                    "Equatorial Guinea",
                    "Eritrea",
                    "Ethiopia",
                    "Gabon",
                    "Gambia",
                    "Ghana",
                    "Gibraltar",
                    "Guinea",
                    "Guinea-Bissau",
                    "Côte d'Ivoire",
                    "Kenya",
                    "Lesotho",
                    "Liberia",
                    "Libya",
                    "Madagascar",
                    "Malawi",
                    "Mali",
                    "Mauritania",
                    "Mauritius",
                    "Morocco",
                    "Mozambique",
                    "Namibia",
                    "Niger",
                    "Nigeria",
                    "Rwanda",
                    "Sao Tome and Principe",
                    "Senegal",
                    "Seychelles",
                    "Sierra Leone",
                    "Somalia",
                    "South Africa",
                    "Sudan",
                    "Swaziland",
                    "United Republic of Tanzania",
                    "Togo",
                    "Tunisia",
                    "Uganda",
                    "Zambia",
                    "Zimbabwe"
                ]
            };

            return this._select_field(field, value, "Default Country Selection", countries, true);

        },

        options: function (field, value) {

            var options = $('<div class="form-group"><label class="control-label col-xs-3 col-sm-3 col-md-3">Options</label></div>');

            if (value['required'] != undefined) {
                var requiredCheckBox = $('<input type="checkbox" />')
                    .click(this._checkUpdate(field, value['required']))
                    .prop('checked', field.data()[value['required']]);
                options.append($('<div class="col-xs-9 col-sm-9 col-md-9">').append($('<label class="checkbox">Required</label>').append(requiredCheckBox)));
            }

            if (value['unique'] != undefined) {
                var uniqueField = $('<input type="checkbox" />')
                    .click(this._checkUpdate(field, value['unique']))
                    .prop('checked', field.data()[value['unique']]);
                options.append($('<div class="col-xs-9 col-sm-9 col-md-9">').append($('<label class="checkbox">No Duplicate</label>').append(uniqueField)));
            }

            return options;
        },

        range: function (field, value, types) {
            var minField = $('<input type="text" class="form-control">')
                .val(field.data()[value['min']])
                .keyup(this._numberUpdater(field, value['min']));
            var maxField = $('<input type="text" class="form-control">')
                .val(field.data()[value['max']])
                .keyup(this._numberUpdater(field, value['max']));

            var typeSelectField = $('<select class="form-control">');

            $.each(types, function (i, type) {
                typeSelectField.append($('<option>')
                    .val(type)
                    .html(type.capitalize()));
            });

            typeSelectField.val(field.data()[value['type']]);
            typeSelectField.change(this._selectUpdate(field, value['type']));

            return $('<div class="form-group"><label class="control-label col-xs-3 col-sm-3 col-md-3">Range</label></div>')
                .append($('<div class="range col-xs-9 col-sm-9 col-md-9">')
                    .append($('<div class="col-xs-3 col-sm-3 col-md-3"><label class="clear">Min</label></div>')
                        .append(minField))
                    .append($('<div class="col-xs-3 col-sm-3 col-md-3"><label>Max</label></span>')
                        .append(maxField))
                    .append($('<div class="col-xs-4 col-sm-4 col-md-4"><label>Format</label></span>')
                        .append(typeSelectField)));
        },

        choices: function (field, value, radio) {
            var firstCheck = true;
            var choices = $('<ul></ul>');
            var id = $().nextNumber();

            var createCheckboxLi = function (field, checkbox) {

                var box;

                if (radio) {
                    box = $('<input type="radio">')
                        .attr('name', "choice" + id)
                        .prop('checked', checkbox.checked)
                        .change(function () {

                            // uncheck all others
                            $.each(field.data()[value], function () {
                                this.checked = false;
                            });
                            checkbox.checked = true;
                            field.update();
                        });

                } else {
                    box = $('<input type="checkbox">')
                        .prop('checked', checkbox.checked)
                        .change(function () {
                            checkbox.checked = $(this).is(':checked');
                            field.update();
                        });
                }

                var div = $('<div class="col-xs-11 col-sm-11 col-md-11"></div>')
                    .append($('<div class="col-xs-1 col-sm-1 col-md-1"></div>')
                        .append(box))
                    .append($('<div class="col-xs-7 col-sm-7 col-md-7">')
                        .append($('<input type="text" class="form-control">')
                            .keyup(function () {
                                checkbox.text = $(this).val();
                                field.update();
                            })
                            .val(checkbox.text)))
                    .append($('<div class="col-xs-1 col-sm-1 col-md-1">')
                        .append($('<img src="/assets/actions/16/add.png" />')
                            .click(function () {
                                var newCheckboxData = { text: "", checked: false};
                                var checkArray = field.data()[value];
                                checkArray.splice(checkArray.indexOf(checkbox) + 1, 0, newCheckboxData);
                                var duplicate = createCheckboxLi(field, newCheckboxData);
                                div.after(duplicate);
                                field.update();
                            })));

                if (!firstCheck) {
                    div.append($('<div class="col-xs-1 col-sm-1 col-md-1">')
                            .append($('<img src="/assets/actions/16/delete.png" />')
                            .click(function () {
                                var data = field.data();
                                data[value] = $.grep(data[value], function (c) {
                                    return c != checkbox;
                                });
                                div.remove();
                                field.update(data);
                            })));
                }
                firstCheck = false;

                return $('<li></li>').append(div);
            };

            $.each(field.data()[value], function (i, checkbox) {
                choices.append(createCheckboxLi(field, checkbox));
            });

            return $('<div class="form-group"><label class="control-label col-xs-3 col-sm-3 col-md-3">Choices</label></div>')
                .append($('<div class="col-xs-9 col-sm-9 col-md-9"></div>').append(choices));

        }

    },

    showFieldConfig: function (field) {
        // show the properties
        this.elementConfig.find("> *").detach();
        this.elementConfig.append(field.settings);
    },

    showFieldPreview: function (field) {
        this.elementPreview.find("> *").detach();
        var previewWrapper = $("<div class='container'></div>")
            .attr('id', "field-" + $().unique())
            .addClass('field');
        field.wrapper = previewWrapper;
        field.tmpl.appendTo(previewWrapper);


        this.elementPreview.append(previewWrapper);
    },

    removeField: function (field) {
        field.wrapper.fadeOut('slow', function () {
            $(this).remove();
        });
        this.elementConfig.find("> *").detach();
    },

    showFieldForMorph: function (morph) {
        this.currMorphRef = morph
        this.showField(morph.fbField)
    },

    showField: function (field) {
        this.lastConfiguredField = field;

        this.setFieldSelection(field);
        this.showFieldPreview(field);
        this.showFieldConfig(field);
    },

    // value is optional
    createAndShowField: function (fieldType, value) {
        var field = fieldType.constructField(value);
        this.showField(field);
    },

    setFieldSelection: function (field) {
        this.elementList.val(field.data().type);
    },

    init: function (input_element_list, input_element_preview, input_element_config) {
        this.elementList = input_element_list;
        this.elementPreview = input_element_preview;
        this.elementConfig = input_element_config;

        if(input_element_list === undefined || input_element_list === null) {
            return;
        }

        $.each(this.fieldTypes, function () {
            var formField = this;
            var formFieldWidget = formField.constructWidget();
            input_element_list.append(formFieldWidget);
        });

        input_element_list.change(function (e) {
            FB.createAndShowField(FB.findFieldType($(this).val()));
            return false;
        });
    }
};

FB.Field = function (tmpl) {
    this.tmpl = tmpl;
    this.settings = null;
    this.wrapper = null;
    this.position = null;
};

FB.Field.prototype.data = function () {
    return this.tmpl.tmplItem().data;
};

FB.Field.prototype.design_ui_txt = function () {
    var fData = this.tmpl.tmplItem().data;
    var txt = (fData.default_text === "" || fData.default_text === undefined) ? fData.label_text : fData.default_text;
    return txt;
};

FB.Field.prototype.update = function (data) {
    var tmpl = this.tmpl.tmplItem();
    tmpl.data = data || this.data();
    this.tmpl = tmpl.update();
};

FB.fieldTypeBuilder({
    type: 'text',

    widgetName: "Single Line Text",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.predefined_value(field, "default_text"))
                .append(FB.fieldSettings.field_size(field, "field_size"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }))
                .append(FB.fieldSettings.range(field,
                    {
                        min: "range_min",
                        max: "range_max",
                        type: "range_type"
                    },
                    ['characters', 'words']
                ));

    },

    default_value: {
        label_text: "Untitled",
        default_text: "",
        field_size: "medium",
        required: false,
        range_min: null,
        range_max: null,
        range_type: 'characters'
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>\
<input class="${field_size} form-control form-morph" id="field${id}" type="text"                \
value="${default_text}" readonly="readonly"/>      \
</div>\
</div>                                                                  \
')

});

FB.fieldTypeBuilder({
    type: 'number',

    widgetName: "Number",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.predefined_value(field, "default_text"))
                .append(FB.fieldSettings.field_size(field, "field_size"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }))
                .append(FB.fieldSettings.range(field,
                    {
                        min: "range_min",
                        max: "range_max",
                        type: "range_type"
                    },
                    ['value', 'digits']));

    },

    default_value: {
        label_text: "Number",
        default_text: "",
        field_size: "medium",
        required: false,
        range_min: null,
        range_max: null,
        range_type: 'value'
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>\
<input class="${field_size} form-control form-morph" id="field${id}" type="text"                \
value="${default_text}" readonly="readonly"  />      \
</div>                                                                  \
</div>\
')
});

FB.fieldTypeBuilder({
    type: 'textarea',

    widgetName: "Paragraph Text",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.predefined_value(field, "default_text"))
                .append(FB.fieldSettings.field_size(field, "field_size"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }))
                .append(FB.fieldSettings.range(field,
                    {
                        min: "range_min",
                        max: "range_max",
                        type: "range_type"
                    },
                    ['characters', 'words']
                ));

    },

    default_value: {
        label_text: "Untitled",
        default_text: "",
        field_size: "medium",
        required: false,
        range_min: null,
        range_max: null,
        range_type: 'characters'
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
</div>\
<textarea class="${field_size} form-control form-morph" id="field${id}" type="text"             \
readonly="readonly"  >\
${default_text}\
</textarea>                                                             \
</div>\
</div>                                                                  \
')

});

FB.fieldTypeBuilder({
    type: 'checkbox',

    widgetName: "Checkboxes",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.field_layout(field, "field_layout"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }))
                .append(FB.fieldSettings.choices(field, "checkboxes", false));
    },

    default_value: {
        label_text: "Check All That Apply",
        field_layout: "one_column",
        checkboxes: [
            {
                text: "First Choice",
                checked: false
            },
            {
                text: "Second Choice",
                checked: false
            },
            {
                text: "Third Choice",
                checked: false
            }
        ],
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div class="${field_layout}">                                           \
{{each(i, c) checkboxes}}                                               \
<div class="column">                                                    \
<input type="checkbox" class="form-morph" {{if c.checked}} checked="checked" {{/if}}       \
readonly="readonly"  disabled="disabled"/>                              \
<label class="control-label">${c.text}</label>                                                \
</div>                                                                  \
{{/each }}                                                              \
</div>                                                                  \
</div>                                                                  \
')
});

FB.fieldTypeBuilder({
    type: 'radio',

    widgetName: "Mulitple Choice",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.field_layout(field, "field_layout"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }))
                .append(FB.fieldSettings.choices(field, "radios", true));
    },

    default_value: {
        label_text: "Select a Choice",
        field_layout: "one_column",
        radios: [
            {
                text: "First Choice",
                checked: false
            },
            {
                text: "Second Choice",
                checked: false
            },
            {
                text: "Third Choice",
                checked: false
            }
        ],
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div class="${field_layout}">                                           \
{{each(i, c) radios}}                                                   \
<div class="column">                                                    \
<input type="radio" class="form-morph" {{if c.checked}} checked="checked" {{/if}}          \
readonly="readonly"  disabled="disabled" name="radio-${id}"/>            \
<label>${c.text}</label>                                                \
</div>                                                                  \
{{/each }}                                                              \
</div>                                                                  \
</div>                                                                  \
')
});

FB.fieldTypeBuilder({
    type: 'select',

    widgetName: "Dropdown",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.field_size(field, "field_size"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }))
                .append(FB.fieldSettings.choices(field, "options", true));
    },

    default_value: {
        label_text: "Select a Choice",
        field_size: "medium",
        options: [
            {
                text: "First Choice",
                checked: false
            },
            {
                text: "Second Choice",
                checked: false
            },
            {
                text: "Third Choice",
                checked: false
            }
        ],
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>\
<select class="${field_size} form-control form-morph"  readonly="readonly" >                                          \
<option value="" readonly="readonly"  disabled="disabled">--Select--</option>  \
{{each(i, c) options}}                                                  \
<option value="${c.text}" {{if c.checked}} selected="selected" {{/if}}  \
readonly="readonly"  disabled="disabled">                               \
${c.text}                                                               \
</div>                                                                  \
{{/each }}                                                              \
</select>                                                               \
</div>\
</div>                                                                  \
')
});

FB.fieldTypeBuilder({
    type: 'name',

    widgetName: "Name",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.name_format(field, "name_format"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }));

    },

    default_value: {
        label_text: "Name",
        name_format: "normal",
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>                                                                   \
{{if name_format == "extended" }}                                       \
<div class="col-xs-2 col-sm-2 col-md-2">                                                   \
  <input type="text" size="5" class="form-control form-morph" readonly="readonly"  />\
  <label>Title</label>                                                  \
</div>                                                                 \
{{/if}}                                                                 \
<div class="col-xs-4 col-sm-4 col-md-4">                                                   \
  <input type="text" size="15" class="form-control form-morph" readonly="readonly" />\
  <label>First</label>                                                  \
</div>                                                                 \
<div class="col-xs-4 col-sm-4 col-md-4">                                                   \
  <input type="text" size="15" class="form-control form-morph" readonly="readonly" />\
  <label>Last</label>                                                   \
</div>                                                                 \
{{if name_format == "extended" }}                                       \
<div class="col-xs-2 col-sm-2 col-md-2">                                                   \
  <input type="text" size="5" class="form-control form-morph" readonly="readonly" /> \
  <label>Suffix</label>                                                 \
</div>                                                                 \
{{/if}}                                                                 \
</div>                                                                  \
</div>                                                                  \
')

});

FB.fieldTypeBuilder({
    type: 'date',

    widgetName: "Date",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.date_format(field, "date_format"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }));

    },

    default_value: {
        label_text: "Date",
        date_format: "mm/dd/yyyy",
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>                                                                   \
<div class="col-xs-2 col-sm-2 col-md-2">                                                   \
  <input type="text" size="2" class="form-control form-morph" readonly="readonly" /> \
<label class="control-label">${date_format.split("/")[0].toUpperCase()}</label>               \
</div>                                                                 \
<div class="col-xs-2 col-sm-2 col-md-2">                                                   \
  <input type="text" size="2" class="form-control form-morph" readonly="readonly" /> \
  <label class="control-label">${date_format.split("/")[1].toUpperCase()}</label>             \
</div>                                                                 \
<div class="col-xs-3 col-sm-3 col-md-3">                                                   \
  <input type="text" size="4" class="form-control form-morph" readonly="readonly" /> \
  <label class="control-label">YYYY</label>                                                   \
</div>                                                                 \
<img src="/assets/fields/calendar.gif" class="calendar" />                     \
</div>                                                                  \
')

});

FB.fieldTypeBuilder({
    type: 'file',

    widgetName: "File Upload",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }));

    },

    default_value: {
        label_text: "Upload a File",
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>\
<input id="field${id}" type="file"                                      \
readonly="readonly" class="form-control form-morph" disabled="disabled" />                              \
</div>\
</div>                                                                  \
')

});

FB.fieldTypeBuilder({
    type: 'address',

    widgetName: "Address",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }))
                .append(FB.fieldSettings.country_options(field, "country"));

    },

    default_value: {
        label_text: "Address",
        required: false,
        country: ""
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>                                                                   \
<div class="col-xs-10 col-sm-10 col-md-10">                                                  \
  <input type="text" class="form-control form-morph" readonly="readonly" /> \
  <label class="control-label">Street Address</label>                                         \
</div>                                                                 \
<div class="col-xs-10 col-sm-10 col-md-10">                                                  \
  <input type="text" class="form-control form-morph" readonly="readonly" /> \
<label class="control-label">Address Line 2</label>                                           \
</div>                                                                 \
<div class="col-xs-8 col-sm-8 col-md-8">                                                   \
  <input type="text" class="form-control form-morph" readonly="readonly"  /> \
<label class="control-label">City</label>                                                     \
</div>                                                                 \
<div class="col-xs-8 col-sm-8 col-md-8">                                                   \
  <input type="text" class="form-control form-morph" readonly="readonly" /> \
<label class="control-label">State / Province / Region</label>                                \
</div>                                                                 \
<div class="col-xs-5 col-sm-5 col-md-5">                                                   \
  <input type="text" class="form-control form-morph" readonly="readonly" /> \
<label class="control-label">Postal / Zip code</label>                                        \
</div>                                                                 \
<div class="col-xs-5 col-sm-5 col-md-5">                                                   \
  <select class="form-control form-morph">                                               \
    <option val="${country}">                                           \
     ${country}                                                         \
    </option>                                                           \
  </select>                                                             \
  <label class="control-label">Country</label>                                                \
</div>                                                                 \
</div>                                                                  \
</div>                                                                  \
')

});

FB.fieldTypeBuilder({
    type: 'email',

    widgetName: "Email",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.predefined_value(field, "default_text"))
                .append(FB.fieldSettings.field_size(field, "field_size"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }));

    },

    default_value: {
        label_text: "Email",
        default_text: "",
        field_size: "medium",
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>\
<input class="${field_size} form-control form-morph" id="field${id}" type="text"                \
value="${default_text}" readonly="readonly"  />      \
</div>                                                                  \
</div>\
')

});

FB.fieldTypeBuilder({
    type: 'time',

    widgetName: "Time",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }));

    },

    default_value: {
        label_text: "Time",
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>                                                                   \
<div class="col-xs-2 col-sm-2 col-md-2">                                                   \
  <input type="text" size="2" class="form-control form-morph" readonly="readonly" /> \
<label class="control-label">HH</label>                                                       \
</div>                                                                 \
<div class="col-xs-2 col-sm-2 col-md-2">                                                   \
  <input type="text" size="2" class="form-control form-morph" readonly="readonly" /> \
<label class="control-label">MM</label>                                                       \
</div>                                                                 \
<div class="col-xs-2 col-sm-2 col-md-2">                                                   \
  <input type="text" size="2" class="form-control form-morph" readonly="readonly" /> \
<label class="control-label">SS</label>                                                       \
</div>                                                                 \
<div class="col-xs-3 col-sm-3 col-md-3">                                                   \
<select class="form-control form-morph">                                                                \
 <option value="am" selected="selected">AM</option>                     \
 <option value="pm" >PM</option>                                        \
</select>                                                               \
<label class="control-label">AM/PM</label>                                                    \
</div>                                                                 \
</div>                                                                  \
</div>                                                                  \
')

});

FB.fieldTypeBuilder({
    type: 'website',

    widgetName: "Website",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.predefined_value(field, "default_text"))
                .append(FB.fieldSettings.field_size(field, "field_size"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }));

    },

    default_value: {
        label_text: "Website",
        default_text: "",
        field_size: "medium",
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>\
<input class="${field_size} form-control form-morph" id="field${id}" type="text"                \
value="${default_text}" readonly="readonly"  />      \
</div>\
</div>                                                                  \
')

});

FB.fieldTypeBuilder({
    type: 'phone',

    widgetName: "Phone",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
                .append(FB.fieldSettings.label(field, "label_text"))
                .append(FB.fieldSettings.phone_format(field, "phone_format"))
                .append(FB.fieldSettings.options(field, {
                    required: "required"
                }));

    },

    default_value: {
        label_text: "Phone",
        phone_format: "other",
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>\
<div>                                                                   \
{{if phone_format == "international" }}                                 \
<input class="form-control form-morph" id="field${id}" type="text"                       \
value="" readonly="readonly"  />                     \
{{else}}                                                                \
<div class="col-xs-3 col-sm-3 col-md-3">                                                   \
  <input type="text" size="2" class="form-control form-morph" readonly="readonly"  />\
<label>###</label>                                                      \
</div>                                                                 \
<div class="col-xs-3 col-sm-3 col-md-3">                                                   \
  <input type="text" size="2" class="form-control form-morph" readonly="readonly" /> \
<label>###</label>                                                      \
</div>                                                                 \
<div class="col-xs-2 col-sm-2 col-md-2">                                                   \
  <input type="text" size="2" class="form-control form-morph" readonly="readonly" /> \
<label>###</label>                                                      \
</div>                                                                 \
{{/if}}                                                                 \
</div>                                                                  \
</div>\
</div>                                                                  \
')

});


FB.fieldTypeBuilder({
    type: 'signature',

    widgetName: "Signature",

    settings: function (field) {
        return $('<form class="form-horizontal" role="form">')
            .append(FB.fieldSettings.label(field, "label_text"))
            .append(FB.fieldSettings.options(field, {
                required: "required"
            }));

    },

    default_value: {
        label_text: "Signature",
        required: false
    },

    template: $.template(null, '                                       \
<div>                                                                   \
<label class="control-label" for="field${id}">${label_text}                      \
{{if required}}                                                         \
<span class="required">*</span>                                         \
{{/if}}                                                                 \
</label>                                                                \
<div>\
<input class="medium form-control form-morph" id="field${id}" type="text"                \
value="" readonly="readonly"  />      \
</div>\
</div>                                                                  \
')

});