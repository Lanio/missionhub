$ ->
  $(document).ready ->

    $(document).on "click", ".side-search-option .toggler", (e)->
      fields = $(this).siblings(".fields")
      parent = $(this).parents(".side-search-option")
      if fields.is(":visible")
        fields.slideUp("fast")
        $(this).removeClass("active")
        parent.removeClass("active")
      else
        $(this).addClass("active")
        parent.addClass("active")
        fields.slideDown("fast")
        $(".side-search-option.singleton.active").each ->
          id = $(this).data("id")
          if id != parent.data("id")
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

    # Show apply button for standard filter
    $(".side-search-option .checkbox input[type='checkbox']").on "click", (e)->
      apply = $(this).parents(".fields")
      apply.find(".actions .apply").show()
      apply.find(".actions .clear").hide()


    # Clear filter
    $(".side-search-option .clear_filter").on "click", (e)->
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
        field = parent.find(".field input")
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
        options = actions.siblings(".options")
        options.find(".text_option").first().children("input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text("Match Any")
        options.find(".selected").show()
        field = parent.find(".field input")
        field.prop("checked", false)

      parent.find(".actions .apply").show()
      parent.find(".actions .clear").hide()

    # Reset filter
    $(".side-search-option .reset_filter").on "click", (e)->
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
        options = actions.siblings(".options")
        options.find(".text_option." + option + " input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text(option_title)
        options.find(".selected").show()
        field.val(value)
        field.keyup()
      else if type == "ChoiceField"
        options = actions.siblings(".options")
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
        options = actions.siblings(".options")
        options.find(".text_option." + option + " input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text(option_title)
        options.find(".selected").show()

        fields = parent.find(".dateselect select")
        fields.each ->
          $(this).val($(this).data("value"))
      else if type == "Standard"
        options = actions.siblings(".options")
        options.find(".text_option." + option + " input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text(option_title)
        options.find(".selected").show()

        fields = actions.siblings(".field").find(".option.checkbox")
        checkboxes = fields.find("input[type='checkbox']")
        checkboxes.prop("checked", false)
        for val in value
          fields.find("input[type='checkbox'][value='" + val + "']").prop("checked", true)

      parent.find(".actions .apply").hide()
      parent.find(".actions .clear").show() if value != ""


    # Toggle option if the parent is clicked
    $(".options .selected").on "click", (e)->
      $(this).hide()
      $(this).siblings(".choices").slideDown()

    # Show apply button for dateselect fields
    $(".side-search-option .dateselect select").on "change", (e)->
      apply = $(this).parents(".side-search-option").find(".actions")
      apply.find(".apply").show()
      apply.find(".clear").hide()


    # Show options when the selected option is clicked
    $(".options .choices .text_option").on "click", (e)->
      input = $(this).children('input')
      unless input.is(":disabled")
        input.prop("checked", true)
        # Show apply button for survey question
        apply = $(this).parents(".options").siblings(".actions")
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
    $(".field .textfield").on
      keyup: (e)->
        options = $(this).parents(".field").siblings(".options")
        contains = options.children(".choices").children(".text_option.contains").children("input")
        is_exactly = options.children(".choices").children(".text_option.is_exactly").children("input")
        does_not_contain = options.children(".choices").children(".text_option.does_not_contain").children("input")
        is_blank = options.children(".choices").children(".text_option.is_blank").children("input")
        is_not_blank = options.children(".choices").children(".text_option.is_not_blank").children("input")

        # Show apply button for survey question
        apply = $(this).parents(".field").siblings(".actions")
        apply.find(".apply").show()
        apply.find(".clear").hide()

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