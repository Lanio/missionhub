$ ->
  $(document).ready ->

    $(document).on "click", ".side-search-option .toggler", (e)->
      fields = $(this).siblings(".fields")
      parent = $(this).parents(".side-search-option")
      if fields.is(":visible")
        fields.slideUp("fast")
        $(this).removeClass("active")
        parent.removeClass("active")
        if parent.data("set") == false
          parent.find(".options").removeClass("active")
      else
        parent.find(".options").addClass("active")
        $(this).addClass("active")
        parent.addClass("active")
        fields.slideDown("fast")
        $(".side-search-option.singleton.active").each ->
          id = $(this).data("id")
          if id != parent.data("id")
            if $(this).data("set") == false
              $(this).find(".options").removeClass("active")
            $(this).find("a.reset_filter").click()
            $(this).find(".fields").slideUp("fast")
            $(this).find(".toggler").removeClass("active")
            $(this).removeClass("active")


    $(document).on "click", ".side-search-option .title", (e)->
      $(this).siblings(".toggler").click()

    $(document).on "click", ".side-search .side-search-toggler", (e)->
      toggler= $(this)
      fields = toggler.siblings(".side-search-options")
      if fields.is(":visible")
        toggler.removeClass("active")
        fields.slideUp "fast"
      else
        toggler.addClass("active")
        fields.slideDown "fast"

    # Show apply button for standard filter (active)
    $(document).on "click", ".side-search-option .fields_active .checkbox input[type='checkbox']", (e)->
      apply = $(this).parents(".fields_active").siblings(".fields")
      apply.find(".actions .apply").show()
      apply.find(".actions .clear").hide()
      unless apply.is(":visible")
        parent = apply.parents(".side-search-option")
        toggler = parent.find(".toggler")
        toggler.addClass("active")
        parent.addClass("active")
        apply.slideDown("fast")

    # Show apply button for standard filter
    $(document).on "click", ".side-search-option .fields .checkbox input[type='checkbox']", (e)->
      apply = $(this).parents(".fields")
      apply.find(".actions .apply").show()
      apply.find(".actions .clear").hide()


    # Clear filter
    $(document).on "click", ".side-search-option .clear_filter", (e)->
      e.preventDefault()
      parent = $(this).parents(".side-search-option")
      # Values
      type = parent.data("type")
      # Elements
      actions = $(this).parents(".actions")

      if type == "TextField"
        options = actions.siblings(".options")
        options.find(".text_option").last().children("input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text("Any Response")
        options.find(".selected").show()
        field = parent.find(".field input")
        field.val("")
        field.keyup()
      else if type == "ChoiceField"
        options = actions.siblings(".options")
        options.find(".text_option").first().children("input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text("Match Any")
        options.find(".selected").show()
        field = parent.find(".fields input")
        field.prop("checked", false)
      else if type == "DateField"
        options = actions.siblings(".options")
        options.find(".text_option").first().children("input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text("Exact")
        options.find(".selected").show()
        fields = parent.find(".dateselect select")
        fields.each ->
          $(this).val($(this).data("null"))
      else if type == "Standard"
        options = parent.find(".options")
        options.find(".text_option").first().children("input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text("Match Any")
        options.find(".selected").show()
        field = parent.find(".fields .option.checkbox input, .fields_active .option.checkbox input")
        field.prop("checked", false)

      parent.find(".actions .apply").show()
      parent.find(".actions .clear").hide()

    # Reset filter
    $(document).on "click", ".side-search-option .reset_filter", (e)->
      e.preventDefault()
      parent = $(this).parents(".side-search-option")
      # Values
      type = parent.data("type")
      value = parent.data("value")
      option = parent.data("option")
      option_title = parent.data("option-title")
      # Elements
      field = parent.find(".field input")
      actions = $(this).parents(".actions")

      if type == "TextField"
        options = actions.parents(".fields").siblings(".options")
        options.find(".text_option." + option + " input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text(option_title)
        options.find(".selected").show()
        field.val(value)
        field.keyup()
      else if type == "ChoiceField"
        options = actions.parents(".fields").siblings(".options")
        options.find(".text_option." + option + " input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text(option_title)
        options.find(".selected").show()

        fields = parent.find(".option.checkbox")
        checkboxes = fields.find("input[type='checkbox']")
        checkboxes.prop("checked", false)
        for val in value
          fields.find("input[type='checkbox'][value='" + val + "']").prop("checked", true)
      else if type == "DateField"
        options = actions.parents(".fields").siblings(".options")
        options.find(".text_option." + option + " input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text(option_title)
        options.find(".selected").show()

        fields = parent.find(".dateselect select")
        fields.each ->
          $(this).val($(this).data("value"))
      else if type == "Standard"
        options = actions.parents(".fields").siblings(".options")
        options.find(".text_option." + option + " input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text(option_title)
        options.find(".selected").show()

        actions.parents(".fields").find(".option.checkbox input").prop("checked", false)
        actions.parents(".fields").siblings(".fields_active").find(".option.checkbox input").prop("checked", true)

      parent.find(".actions .apply").hide()
      parent.find(".actions .clear").show() if value != ""


    # Toggle option if the parent is clicked
    $(document).on "click", ".options .selected", (e)->
      $(this).hide()
      $(this).siblings(".choices").slideDown()
      unless $(this).parents(".options").siblings(".fields").is(":visible")
        $(this).parents(".options").siblings(".toggler").click()

    # Show apply button for dateselect fields
    $(document).on "change", ".side-search-option .dateselect select", (e)->
      apply = $(this).parents(".side-search-option").find(".actions")
      apply.find(".apply").show()
      apply.find(".clear").hide()


    # Show options when the selected option is clicked
    $(document).on "click", ".options .choices .text_option", (e)->
      input = $(this).children('input')
      unless input.is(":disabled")
        input.prop("checked", true)
        # Show apply button for survey question
        apply = $(this).parents(".options").siblings(".fields").find(".actions")
        apply.find(".apply").show()
        apply.find(".clear").hide()
        # Parent based behavior
        parent = input.parents(".side-search-option")
        if parent.data("type") == "DateField"
          if input.val() == "match"
            parent.find(".field .dateselect.end .dateselect_intro").addClass("inactive")
            parent.find(".field .dateselect.end .dateselect_label").addClass("inactive")
            parent.find(".field .dateselect.end select").prop("disabled", true)
          else
            parent.find(".field .dateselect.end .dateselect_intro").removeClass("inactive")
            parent.find(".field .dateselect.end .dateselect_label").removeClass("inactive")
            parent.find(".field .dateselect.end select").prop("disabled", false)

    # Disable some options when no keyword is defined
    $(document).on "keyup", ".field .textfield", (e)->
      parent = $(this).parents(".side-search-option")
      options = parent.find(".options")
      contains = options.children(".choices").children(".text_option.contains").children("input")
      is_exactly = options.children(".choices").children(".text_option.is_exactly").children("input")
      does_not_contain = options.children(".choices").children(".text_option.does_not_contain").children("input")
      is_blank = options.children(".choices").children(".text_option.is_blank").children("input")
      is_not_blank = options.children(".choices").children(".text_option.is_not_blank").children("input")

      # Show apply button for survey question
      apply = parent.find(".actions")
      apply.find(".apply").show()
      apply.find(".clear").hide()

      unless parent.find(".fields").is(":visible")
        parent.find(".toggler").click()

      if $(this).val() == ""
        if contains.is(":checked") || is_exactly.is(":checked") || does_not_contain.is(":checked")
          is_not_blank.prop("checked", true)
          options.find(".selected").text("Any Response")
        contains.prop("disabled", true)
        is_exactly.prop("disabled", true)
        does_not_contain.prop("disabled", true)
      else
        if is_blank.is(":checked") || is_not_blank.is(":checked")
          contains.prop("checked", true)
          options.find(".selected").text("Contains")
        contains.prop("disabled", false)
        is_exactly.prop("disabled", false)
        does_not_contain.prop("disabled", false)