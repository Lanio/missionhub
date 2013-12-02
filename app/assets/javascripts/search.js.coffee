$ ->
  $(document).ready ->

    $(document).on "click", ".side-search-option .toggler", (e)->
      fields = $(this).siblings(".fields")
      if fields.is(":visible")
        fields.slideUp("fast")
        $(this).removeClass("active")
      else
        fields.slideDown("fast")
        $(this).addClass("active")

    $(document).on "click", ".side-search-title", (e)->
      fields = $(this).siblings(".side-search-options")
      if fields.is(":visible")
        fields.slideUp("fast")
      else
        fields.slideDown("fast")