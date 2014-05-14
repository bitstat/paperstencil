user = User.find_by_email("demo@paperstencil.com")

unless user
  user = User.new(:email => "demo@paperstencil.com",
                  :password => "123456",
                  :password_confirmation => "123456",
                  :first_name => "User",
                  :last_name => "Demo"
  )
  user.skip_confirmation!
  user.save!
end

doc_array = Document.create!([
                                 {
                                     user_id: user.id,
                                     title: "Product sales agreement",
                                     value: {
                                         "meta" => {
                                             "morph" => "WordProcessor.Element.Struct.DocMorph"
                                         },
                                         "data" => [
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph",
                                                     "style" => "style_justify_morph_center"
                                                 },
                                                 "data" => [
                                                     " ",
                                                     {
                                                         "meta" => {
                                                             "morph" => "WordProcessor.Core.UnknownElementMorph",
                                                             "node_name" => "SPAN",
                                                             "attributes" => {
                                                                 "style" => "text-decoration:underline",
                                                                 "class" => "style_selection_underlinehmorph style_selectionstylemorph"
                                                             }
                                                         },
                                                         "data" => [
                                                             {
                                                                 "meta" => {
                                                                     "morph" => "WordProcessor.Core.UnknownElementMorph",
                                                                     "node_name" => "SPAN",
                                                                     "attributes" => {
                                                                         "style" => "font-weight:bold",
                                                                         "class" => "style_selection_boldmorph style_selectionstylemorph"
                                                                     }
                                                                 },
                                                                 "data" => [
                                                                     "PRODUCT SALES AGREEMENT"
                                                                 ]
                                                             }
                                                         ]
                                                     }
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [
                                                     {
                                                         "meta" => {
                                                             "morph" => "WordProcessor.Core.UnknownElementMorph",
                                                             "node_name" => "SPAN",
                                                             "attributes" => {
                                                                 "style" => "text-decoration:underline",
                                                                 "class" => "style_selection_underlinehmorph style_selectionstylemorph"
                                                             }
                                                         },
                                                         "data" => [
                                                             {
                                                                 "meta" => {
                                                                     "morph" => "WordProcessor.Core.UnknownElementMorph",
                                                                     "node_name" => "SPAN",
                                                                     "attributes" => {
                                                                         "style" => "font-weight:bold",
                                                                         "class" => "style_selection_boldmorph style_selectionstylemorph"
                                                                     }
                                                                 },
                                                                 "data" => [

                                                                 ]
                                                             }
                                                         ]
                                                     },
                                                     {
                                                         "meta" => {
                                                             "morph" => "WordProcessor.Core.UnknownElementMorph",
                                                             "node_name" => "SPAN",
                                                             "attributes" => {
                                                                 "style" => "text-decoration:underline",
                                                                 "class" => "style_selection_underlinehmorph style_selectionstylemorph"
                                                             }
                                                         },
                                                         "data" => [
                                                             {
                                                                 "meta" => {
                                                                     "morph" => "WordProcessor.Core.UnknownElementMorph",
                                                                     "node_name" => "SPAN",
                                                                     "attributes" => {
                                                                         "style" => "font-weight:bold",
                                                                         "class" => "style_selection_boldmorph style_selectionstylemorph"
                                                                     }
                                                                 },
                                                                 "data" => [

                                                                 ]
                                                             }
                                                         ]
                                                     }
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [
                                                     "This product sales agreement (this \"agreement\") is made as of ",
                                                     {
                                                         "meta" => {
                                                             "morph" => "WordProcessor.Element.Content.Widget.FieldMorph",
                                                             "field_ref" => "_7j7xup64rbhme7b9_pu4y9s73teqgds4i"
                                                         },
                                                         "data" => [

                                                         ]
                                                     },
                                                     " "
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [
                                                     "by and between XYZ Applied Research Corporation (\"Seller\") with address"
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [
                                                     "of 071, middle avenue, Atlanda, GA 30332, and ",
                                                     {
                                                         "meta" => {
                                                             "morph" => "WordProcessor.Element.Content.Widget.FieldMorph",
                                                             "field_ref" => "_zmykzm0ukj32qpvi_qpbf27a93cba9k9"
                                                         },
                                                         "data" => [

                                                         ]
                                                     },
                                                     " (the customer)"
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [
                                                     "with an address of ",
                                                     {
                                                         "meta" => {
                                                             "morph" => "WordProcessor.Element.Content.Widget.FieldMorph",
                                                             "field_ref" => "_ttr9cn4i63g3z0k9_rb7rjng0w4uz0k9"
                                                         },
                                                         "data" => [

                                                         ]
                                                     },
                                                     " "
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [

                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph",
                                                     "style" => "style_justify_morph_center"
                                                 },
                                                 "data" => [
                                                     "WITNESSETH"
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [

                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [
                                                     "WHEREAS, Seller wishes to sell solely for demonstration purpose, a certain"
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [
                                                     "product as described below (the \"Product\"), to customer; and"
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [

                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [
                                                     "WHEREAS, Customer desires to purchase the product from Seller pursuant to"
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [
                                                     "the terms and conditions of this agreement."
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [

                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [

                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "rowsCount" => 1,
                                                     "colsCount" => 2,
                                                     "morph" => "WordProcessor.Element.Struct.TableMorph"
                                                 },
                                                 "data" => [
                                                     {
                                                         "meta" => {
                                                             "morph" => "WordProcessor.Element.Struct.TableRowMorph"
                                                         },
                                                         "data" => [
                                                             {
                                                                 "meta" => {
                                                                     "morph" => "WordProcessor.Element.Struct.TableCellMorph",
                                                                     "width" => 53.38680927826911
                                                                 },
                                                                 "data" => [
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [
                                                                             " "
                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [
                                                                             "Seller"
                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [

                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [
                                                                             {
                                                                                 "meta" => {
                                                                                     "morph" => "WordProcessor.Element.Content.Widget.PictureMorph",
                                                                                     "picture_ref" => "_ypuiq69k4wmte29_0gprjmi0eteghkt9"
                                                                                 },
                                                                                 "data" => [

                                                                                 ]
                                                                             },
                                                                             " "
                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [

                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [
                                                                             "Seth Lodd"
                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [
                                                                             "Manager - Products"
                                                                         ]
                                                                     }
                                                                 ]
                                                             },
                                                             {
                                                                 "meta" => {
                                                                     "morph" => "WordProcessor.Element.Struct.TableCellMorph",
                                                                     "width" => 45.263559978549225
                                                                 },
                                                                 "data" => [
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [
                                                                             " Customer"
                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [
                                                                             " "
                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [
                                                                             " ",
                                                                             {
                                                                                 "meta" => {
                                                                                     "morph" => "WordProcessor.Element.Content.Widget.FieldMorph",
                                                                                     "field_ref" => "_upm0pym8yh6ko6r_b3n6h59jo9k3ayvi"
                                                                                 },
                                                                                 "data" => [

                                                                                 ]
                                                                             },
                                                                             " "
                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [

                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [
                                                                             " ",
                                                                             {
                                                                                 "meta" => {
                                                                                     "morph" => "WordProcessor.Element.Content.Widget.FieldMorph",
                                                                                     "field_ref" => "_9x9uf3sg2nbfbt9_k2zf8cnl9y7m0a4i"
                                                                                 },
                                                                                 "data" => [

                                                                                 ]
                                                                             },
                                                                             " "
                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [

                                                                         ]
                                                                     },
                                                                     {
                                                                         "meta" => {
                                                                             "morph" => "WordProcessor.Element.Content.LineMorph"
                                                                         },
                                                                         "data" => [
                                                                             " ",
                                                                             {
                                                                                 "meta" => {
                                                                                     "morph" => "WordProcessor.Element.Content.Widget.FieldMorph",
                                                                                     "field_ref" => "_mfqxdfeb71vjwcdi_una8uwd49vxqolxr"
                                                                                 },
                                                                                 "data" => [

                                                                                 ]
                                                                             },
                                                                             " "
                                                                         ]
                                                                     }
                                                                 ]
                                                             }
                                                         ]
                                                     }
                                                 ]
                                             },
                                             {
                                                 "meta" => {
                                                     "morph" => "WordProcessor.Element.Content.LineMorph"
                                                 },
                                                 "data" => [
                                                     " "
                                                 ]
                                             }
                                         ]
                                     },
                                     share_option: "none",
                                     address: "0aae4b1e-7f3d-11e3-9194-b1bf1f65d4d2",
                                     is_deleted: false
                                 }
                             ])

doc = doc_array[0]

Field.create!([
                  {type: "DateField", value: {"label_text" => "Date", "date_format" => "mm/dd/yyyy", "required" => false, "id" => "_7j7xup64rbhme7b9_pu4y9s73teqgds4i", "type" => "date", "db_id" => 18, "has_error" => false, "error_msg" => nil}, document_id: doc.id},
                  {type: "NameField", value: {"label_text" => "Name", "name_format" => "normal", "required" => false, "id" => "_zmykzm0ukj32qpvi_qpbf27a93cba9k9", "type" => "name", "db_id" => 19, "has_error" => false, "error_msg" => nil}, document_id: doc.id},
                  {type: "AddressField", value: {"label_text" => "Address", "required" => false, "country" => "", "id" => "_ttr9cn4i63g3z0k9_rb7rjng0w4uz0k9", "type" => "address", "db_id" => 20, "has_error" => false, "error_msg" => nil}, document_id: doc.id},
                  {type: "SignatureField", value: {"label_text" => "Signature", "required" => false, "id" => "_upm0pym8yh6ko6r_b3n6h59jo9k3ayvi", "type" => "signature", "db_id" => 21, "has_error" => false, "error_msg" => nil}, document_id: doc.id},
                  {type: "NameField", value: {"label_text" => "Name", "name_format" => "normal", "required" => false, "id" => "_9x9uf3sg2nbfbt9_k2zf8cnl9y7m0a4i", "type" => "name", "db_id" => 22, "has_error" => false, "error_msg" => nil}, document_id: doc.id},
                  {type: "TextField", value: {"label_text" => "Title", "default_text" => "", "field_size" => "medium", "required" => false, "range_min" => nil, "range_max" => nil, "range_type" => "characters", "id" => "_mfqxdfeb71vjwcdi_una8uwd49vxqolxr", "type" => "text", "db_id" => 23, "has_error" => false, "error_msg" => nil}, document_id: doc.id}
              ])

Admin.create!([
                  {email: "demo@paperstencil.com", document_id: doc.id}
              ])

Picture.create!([
                    {ref_id: "_ypuiq69k4wmte29_0gprjmi0eteghkt9", value: {"id" => "_ypuiq69k4wmte29_0gprjmi0eteghkt9", "width" => "133", "height" => "38", "db_id" => 13, "pict_stream" => "data:image/png;base64,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"}, document_id: doc.id}
                ])

