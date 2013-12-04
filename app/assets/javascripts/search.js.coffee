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
        fields.slideDown("fast")
        $(this).addClass("active")
        parent.addClass("active")

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
        field = parent.find(".field input")
        options = actions.siblings(".options")
        field.val("")
        options.find(".text_option").last().children("input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text("Any Response")
        options.find(".selected").show()
        field.keyup()
      else if type == "Standard"
        options = actions.siblings(".option.checkbox")
        checkboxes = options.find("input[type='checkbox']")
        checkboxes.prop("checked", false)

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
        field.val(value)
        options.find(".text_option." + option + " input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text(option_title)
        options.find(".selected").show()
        field.keyup()
      else if type == "Standard"
        options = actions.siblings(".option.checkbox")
        checkboxes = options.find("input[type='checkbox']")
        checkboxes.prop("checked", false)
        for val in value
          options.find("input[type='checkbox'][value='" + val + "']").prop("checked", true)

      parent.find(".actions .apply").hide()
      parent.find(".actions .clear").show() if value != ""


    # Toggle option if the parent is clicked
    $(".options .selected").on "click", (e)->
      $(this).hide()
      $(this).siblings(".choices").slideDown()

    # Show options when the selected option is clicked
    $(".options .choices .text_option").on "click", (e)->
      input = $(this).children('input')
      unless input.is(":disabled")
        input.prop("checked", true)

        # Show apply button for survey question
        apply = $(this).parents(".options").siblings(".actions")
        apply.find(".apply").show()
        apply.find(".clear").hide()

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