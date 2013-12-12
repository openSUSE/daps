$(function() {

  $('body').addClass('js-on');

  $('.question').click(function(){ $(this).parent('dl').toggleClass('active'); });

});
