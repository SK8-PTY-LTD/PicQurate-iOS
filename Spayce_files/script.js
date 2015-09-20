/*	window.load is used instead of document.ready
    when height calculations are needed. This is
    for the sake of webkit-based browsers */
jQuery(window).load(function() {
    var isiPhone = ( navigator.userAgent.match(/(iPhone)/g) ? true : false );
    // define window position and scroll tracking variables
    var windowHeight, windowScrollPosTop, windowScrollPosBottom = 0;
    
    // calculate window position and scroll tracking variables
    function calcScrollValues() {
        windowHeight = jQuery(window).height();
        windowScrollPosTop = jQuery(window).scrollTop();
        windowScrollPosBottom = windowHeight + windowScrollPosTop;
    } // end calcScrollValues
    
    // create revealOnScroll method
    jQuery.fn.revealOnScroll = function(direction, speed) {
        return this.each(function() {
            
            var objectOffset = jQuery(this).offset();
            var objectOffsetTop = objectOffset.top;
            
            // only hide and offset elements once
            if (!jQuery(this).hasClass("hiddenBox")) {
                
                // if argument is "right"
                if (direction == "right") {
                    jQuery(this).css({
                        "opacity"	: 0,
                        "right"		: "700px",
                        "position"	: "relative"
                    });
                // if argument is "left"
                } else {
                    jQuery(this).css({
                        "opacity"	: 0,
                        "right"		: "-700px",
                        "position"	: "relative"
                    });
                    
                } // end if argument is right/left check
                
                jQuery(this).addClass("hiddenBox");	
            } // end only hide and offset elements once logic
            
            // only reveal the element once
            if (!jQuery(this).hasClass("animation-complete")) {
                
                // if the page has been scrolled far enough to reveal the element
                if (windowScrollPosBottom > objectOffsetTop) {
                    jQuery(this).animate({"opacity" : 1, "right" : 0}, speed).addClass("animation-complete");
                } // end if the page has scrolled enough check

            } // end only reveal the element once
            
        });
    } // end revealOnScroll function

    // reveal commands
    function revealCommands() {
        jQuery(".feature-box .rightPadding").revealOnScroll("right", 1000);
        jQuery(".feature-box .leftPadding").revealOnScroll("left", 1000);
    } // end reveal commands
    
    // run the following on initial page load
    calcScrollValues();
    if (!isiPhone) {
        revealCommands();
    }
    // run the following on every scroll event
    jQuery(window).scroll(function() {
        calcScrollValues()
        if (!isiPhone) {
            revealCommands();
        }
    }); // end on scroll
    
});