$(document).ready(function() {
    $(".appIconBox img").hover(function () {
        $(this).toggleClass("animated bounce");
    });
    if (matchMedia('only screen and (max-width:767px)').matches) {
        $(".feature-box.invert-mobile").each(function() {
            var $this = $(this);
            var div1 = $this.find('.rightPadding');
            var div2 = $this.find('.leftPadding');

            var tdiv1 = div1.clone();
            var tdiv2 = div2.clone();

            if(!div2.is(':empty')){
                div1.replaceWith(tdiv2);
                div2.replaceWith(tdiv1);
            }
        });
    }
    $(window).scroll(function() {

        var y = $(this).scrollTop();
         setTimeout(function () {
        }, 5000);

        if (matchMedia('only screen and (max-width:416px)').matches) {
            if(y >= 1) {
                $( ".mapPin02" ).hide(0);
                $('#mapPin01img').css('visibility', 'visible').addClass('animated zoomInUp');
                $('#mapPin03img').css('visibility', 'visible').addClass('animated zoomInUp');
                $(".mapPin01").css({
                    "float": "left",
                    "margin-left": "6%"
                });
                 $(".mapPin03").css({
                    "float": "left",
                    "margin-left": "6%",
                    "margin-bottom": "60px",
                    "margin-top": "70px"
                });
            }
        } else  if (matchMedia('only screen and (max-width:767px)').matches) {
            if(y >= 1) {
                $( ".mapPin02" ).hide(0);
                $('#mapPin01img').css('visibility', 'visible').addClass('animated zoomInUp');
                $('#mapPin03img').css('visibility', 'visible').addClass('animated zoomInUp');
                $(".mapPin01").css({
                    "float": "left",
                    "margin-left": "30%"
                });
                 $(".mapPin03").css({
                    "float": "left",
                    "margin-left": "10%",
                    "margin-bottom": "73px",
                    "margin-top": "70px"
                });
            }
        } else {
            if(y >= 800) {
                $('#mapPin02img').css('visibility', 'visible').addClass('animated zoomInUp');
                setTimeout(function () {
                    $('#mapPin01img').css('visibility', 'visible').addClass('animated zoomInUp');
                }, 200);
                setTimeout(function () {
                    $('#mapPin03img').css('visibility', 'visible').addClass('animated zoomInUp');
                }, 300);
            }
        }

    });
});