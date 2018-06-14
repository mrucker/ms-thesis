$(document).ready( function () {

    initializeCanvas();
    
    if(querystring.exists("noData")) {
        $.ajax = function(params) {
            return $.Deferred().resolve();
        }
    }

    if(querystring.exists("testOnly")) {
        $.Deferred().resolve()
            .then(showModalContent("dialog1", false))
            .then(new Experiment("testOnly").run    )
            .then(showModalContent("dialog7", false))
            .then(showThanks                        );
    } else {
    
        var participant = new Participant();
        var experiment1 = new Experiment(participant.getId());
        var experiment2 = new Experiment(participant.getId());
    
        if(querystring.exists("showId")) {
            alert(participant.getId());
        }
    
        $.Deferred().resolve()
//            .then(showModalContent("welcome"   , true ))            
//            .then(showModalContent("consent"   , true ))            
//            .then(showDemographicForm                  )
//            .then(showModalContent("directions", true ))
            .then(showModalContent("begin1"    , false))
            .then(experiment1.run                      )
            .then(showModalContent("break"     , true))
            .then(showModalContent("begin2"    , false))
            .then(experiment2.run                      )
            .then(showModalContent("finished"  , false))
            .then(showThanks                           );
    }
    
    function showModalContent(contentId, preventDefault) {
        return function() {
                        
            loadModalContent(contentId);

            $("#modal").modal('show');

            var deferred = $.Deferred();            

            $("#modal").on('hide.bs.modal', function (e) {
                if(preventDefault) { 
                    e.preventDefault(); 
                    e.stopPropagation(); 
                }
                
                deferred.resolve();
                
                $("#modal").off('hide.bs.modal');
            });
            
            return deferred;
        };
    }
        
    function showDemographicForm() {
        var deferred = $.Deferred(); 
        
        loadModalContent("demographics");
        
        $("#modal .modal-footer").css("justify-content","space-between");
        $("#modal .modal-footer").prepend('<div id="my-g-recaptcha"></div>');   
        
        var parameters = {
            "sitekey" : "6LeMQ14UAAAAAPoZJhiLTNVdcqr1cV8YEbon81-l"
           , "size"    : "invisible"
           , "badge"   : "inline"
           , "callback": participant.reCAPTCHA
        };

        grecaptcha.render("my-g-recaptcha", parameters);

        $("#modal").on('hide.bs.modal', function (e) {
            var $form = $('#modal form');

            if($form[0].checkValidity()) {
                participant.saveDemographics();

                deferred.resolve();
                
                $("#modal .modal-footer").css("justify-content","flex-end");
                $("#my-g-recaptcha").css("display","none");
                $("#modal").off('hide.bs.modal')
            } 

            e.preventDefault();
            e.stopPropagation();            

            $form.addClass('was-validated');
        });

        return deferred;
    }
    
    function showThanks() {
        $("#c").css("display","none"); $("#thanks").css("display","block");
    }

    function initializeCanvas() {
        var canvas  = new Canvas(document.querySelector('#c'));
        
        canvas.resize($(window).width() - 10, $(window).height() - 10);
        
        $(window).on('resize', function() {
            canvas.resize($(window).width() - 10, $(window).height() - 10);
        });
    }
    
    function loadModalContent(contentId) {
            var $content = $("#" + contentId);

            $("#modalTitle" ).html($content.data('title'));
            $("#modalBody"  ).html($content.html());
            $("#modalButton").html($content.data('btnTxt'));
    }


});