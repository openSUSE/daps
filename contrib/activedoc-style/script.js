$(function() {

  $('body').addClass('js-on');

  $('.question').click(function(){ $(this).parent('dt').parent('dl').toggleClass('active'); });


});
