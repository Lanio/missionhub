$(document).ready(function() {
  $('button#uncheck_all_movements').bind('click', function () {
    $('div#snapshot_movements input.snap_movement').prop({
      disabled: false,
      checked: false
    });
    $('input#snap_all_false').prop('checked',true);
  });
  $('input#snap_all_true').bind('click', function () {
    $('input.snap_movement').prop({
      disabled: true
    });
  });
  $('input#snap_all_false').bind('click', function () {
    $('input.snap_movement').prop({
      disabled: false
    });
  });
  $('div#snapshot_movements_submit input.large_gray').bind('click', function () {
    $('div#snap_container1, div#snap_container2, div#snap_container3, div#snap_numbers').hide();
    $('div#snap_spinner').show();
  });
  $('select#gospel_exp_range').change(function(){
    $('div#snap_container1, div#snap_container2, div#snap_container3, div#snap_numbers').hide();
    $('div#snap_spinner').show();
    $.ajax({
      url: "/charts/update_snapshot_range",
      type: "POST",
      data: {gospel_exp_range: $('select#gospel_exp_range option:selected').val()}
    })
  });
  $('select#laborers_range').change(function(){
    $('div#snap_container1, div#snap_container2, div#snap_container3, div#snap_numbers').hide();
    $('div#snap_spinner').show();
    $.ajax({
      url: "/charts/update_snapshot_range",
      type: "POST",
      data: {laborers_range: $('select#laborers_range option:selected').val()}
    })
  });

  $('select#goal_org_select').change(function(){
    $('div#goal_container, div#goal_box').hide();
    $('div#goal_spinner, div#goal_box_spinner').show();
    $.ajax({
      url: "/charts/update_goal_org",
      type: "POST",
      data: {org_id: $('select#goal_org_select option:selected').val()}
    })
  });
  $('select#goal_criteria_select').change(function(){
    $('div#goal_container, div#goal_box').hide();
    $('div#goal_spinner, div#goal_box_spinner').show();
    $.ajax({
      url: "/charts/update_goal_criteria",
      type: "POST",
      data: {criteria: $('select#goal_criteria_select option:selected').val()}
    })
  });

  $('button#trend_uncheck_all_movements').bind('click', function () {
    $('div#trend_movements input.trend_movement').prop({
      disabled: false,
      checked: false
    });
    $('input#trend_all_false').prop('checked',true);
  });
  $('input#trend_all_true').bind('click', function () {
    $('input.trend_movement').prop({
      disabled: true
    });
  });
  $('input#trend_all_false').bind('click', function () {
    $('input.trend_movement').prop({
      disabled: false
    });
  });
  $('div#trend_movements_submit input.large_gray').bind('click', function () {
    $('div#trend_container').hide();
    $('div#trend_spinner').show();
  });
  $("input.datepicker").datepicker({dateFormat: 'yy-mm-dd'});
  $('div#trend_fields select').change(function() {
    $('div#trend_container').hide();
    $('div#trend_spinner').show();
    $.ajax({
      url: "/charts/update_trend_field",
      type: "POST",
      data: {changed: this.id, criteria: $('select#' + this.id + ' option:selected').val()}
    })
  });
  $('input#trend_compare').change(function() {
    $('div#trend_container').hide();
    $('div#trend_spinner').show();
    $.ajax({
      url: "/charts/update_trend_compare",
      type: "POST",
      data: {compare: $('input#trend_compare').prop('checked')}
    })
  });
});