<header>
    <div class="flexContainer">
        <div class="logo">
            <img src="/assets/OKTO Logo Black.svg" alt="">
        </div>
        <div class="navLinks">
            <a href="#">HOME</a>
            <a href="#">ABOUT</a>
            <a href="#">SERVICES</a>
            <a href="#">CONTACT</a>
        </div>
        <div class="hamburgerContainer">
            <div class="hamburger">
                <svg class="ham ham6" viewBox="0 0 100 100" width="80" onclick="this.classList.toggle('active')">
                    <path class="line top" d="m 30,33 h 40 c 13.100415,0 14.380204,31.80258 6.899646,33.421777 -24.612039,5.327373 9.016154,-52.337577 -12.75751,-30.563913 l -28.284272,28.284272" />
                    <path class="line middle" d="m 70,50 c 0,0 -32.213436,0 -40,0 -7.786564,0 -6.428571,-4.640244 -6.428571,-8.571429 0,-5.895471 6.073743,-11.783399 12.286435,-5.570707 6.212692,6.212692 28.284272,28.284272 28.284272,28.284272" />
                    <path class="line bottom" d="m 69.575405,67.073826 h -40 c -13.100415,0 -14.380204,-31.80258 -6.899646,-33.421777 24.612039,-5.327373 -9.016154,52.337577 12.75751,30.563913 l 28.284272,-28.284272" />
                </svg>
            </div>
        </div>
    </div>
</header>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Select the hamburger icon
        var hamburger = document.querySelector('.hamburger');

        // Add click event to the hamburger icon
        hamburger.addEventListener('click', function() {
            // Select the navigation links
            var navLinks = document.querySelector('.navLinks');

            // Toggle the display style
            if (navLinks.classList.contains('mobileNavLinks')) {
                navLinks.classList.remove('mobileNavLinks');
            } else {
                navLinks.classList.add('mobileNavLinks');
            }
        });
    });
</script>
