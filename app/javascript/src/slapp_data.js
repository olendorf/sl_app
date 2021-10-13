        $(document).ready ( function () {
            $(".navbar-nav a").on('click', function () {
              alert("test");
            	$( '.main-header .navbar-nav' ).find( 'li.active' ).removeClass( 'active' );
            	$( 'a[href="' + this.location.pathname + '"]' ).parent().addClass( 'active' );
            });
        });