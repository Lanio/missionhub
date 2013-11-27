$ ->
  $(document).ready ->

    $(document).on "click", ".side-search-option .toggler", (e)->
      fields = $(this).siblings(".fields")
      if fields.is(":visible")
        $(this).siblings(".fields").slideUp()
        $(this).text("more")
      else
        $(this).siblings(".fields").slideDown()
        $(this).text("less")
