window.ASAP = (->
    fns = []
    callall = () ->
        f() while f = fns.shift()
    if document.addEventListener
        document.addEventListener 'DOMContentLoaded', callall, false
        window.addEventListener 'load', callall, false
    else if document.attachEvent
        document.attachEvent 'onreadystatechange', callall
        window.attachEvent 'onload', callall
    (fn) ->
        fns.push fn
        callall() if document.readyState is 'complete'
)()

log = () ->
    if window.console and window.DEBUG
        console.group? window.DEBUG
        if arguments.length == 1 and Array.isArray(arguments[0]) and console.table
            console.table.apply window, arguments
        else
            console.log.apply window, arguments
        console.groupEnd?()
trouble = () ->
    if window.console
        console.group? window.DEBUG if window.DEBUG
        console.warn?.apply window, arguments
        console.groupEnd?() if window.DEBUG

window.preload = (what, fn) ->
    what = [what] unless  Array.isArray(what)
    $.when.apply($, ($.ajax(lib, dataType: 'script', cache: true) for lib in what)).done -> fn?()

window.queryParam = queryParam = (p, nocase) ->
    params_kv = location.search.substr(1).split('&')
    params = {}
    params_kv.forEach (kv) -> k_v = kv.split('='); params[k_v[0]] = k_v[1] or ''
    if p
        if nocase
            return decodeURIComponent(params[k]) for k of params when k.toUpperCase() == p.toUpperCase()
            return undefined
        else
            return decodeURIComponent params[p]
    params

String::zeroPad = (len, c) ->
    s = ''
    c ||= '0'
    len ||= 2
    len -= @length
    s += c while s.length < len
    s + @
Number::zeroPad = (len, c) -> String(@).zeroPad len, c

window.DEBUG = 'APP NAME'

ASAP ->

    $('body .subpage-search-bg > .background').append $('#_intro_markup').html()

    $flickityReady = $.Deferred()
    preload 'https://cdnjs.cloudflare.com/ajax/libs/flickity/2.3.0/flickity.pkgd.min.js', -> $flickityReady.resolve()

    preload 'https://cdnjs.cloudflare.com/ajax/libs/jquery-scrollTo/2.1.3/jquery.scrollTo.min.js', ->
        $(document).on 'click', '[data-scrollto]', -> $(window).scrollTo $(this).attr('data-scrollto'), 500, offset: -150

    $destinations = $('.destination-performance')

    $.when($flickityReady).done ->
        $('.concept-slider')
        .on 'staticClick.flickity', (event, pointer, cellElement, cellIndex) -> $(this).flickity 'select', cellIndex
        .flickity
            cellSelector: '.slide'
            cellAlign: 'center'
            initialIndex: 1
            wrapAround: no
            prevNextButtons: yes
            pageDots: no
        $ctl_slider = $('.ctl-slider')
        .on 'staticClick.flickity', (event, pointer, cellElement, cellIndex) -> $(this).flickity 'select', cellIndex
        .on 'select.flickity', (event, cellIndex) ->
            $sel = $(Flickity.data(this).selectedElement)
            content_marker = $sel.attr 'data-content-marker'
            group_marker = $sel.attr 'data-selector-group'
            $vbox2select = $destinations.find(".video-bundle [data-content-marker='#{ content_marker }']")
            $vbox2select.addClass('selected').fadeIn(1000).siblings('.selected').removeClass('selected').fadeOut(1000)
            $info2select = $destinations.find(".infos [data-content-marker='#{ content_marker }']")
            $info2select.addClass('selected').siblings('.selected').removeClass('selected')
            setTimeout ->
                $("#hotels-set .group-filters button[data-group='#{ group_marker }']").click()
            , 1000
        .flickity
            cellSelector: '.slide'
            cellAlign: 'left'
            wrapAround: no
            contain: yes
            prevNextButtons: yes
            pageDots: no

        await 1
        $('.flickity-enabled').flickity 'resize'

    responsiveHandler = (query, match_handler, unmatch_handler) ->
        layout = matchMedia query
        layout.addEventListener 'change', (e) ->
            if e.matches then match_handler() else unmatch_handler()
        if layout.matches then match_handler() else unmatch_handler()
        layout

    responsiveHandler '(max-width:768px)',
        ->
            $player_el = $('.video-box.kv .hidden-on-desktop[data-vid]')
            p = new Vimeo.Player $player_el.get(0),
                id: $player_el.attr('data-vid')
                background: 1
                playsinline: 1
                autopause: 0
                title: 0
                byline: 0
                portrait: 0
            p.on 'play', ->
                $player_el.addClass 'playback'
        ->
            $player_el = $('.video-box.kv .hidden-on-mobile[data-vid]')
            p = new Vimeo.Player $player_el.get(0),
                id: $player_el.attr('data-vid')
                background: 1
                playsinline: 1
                autopause: 0
                title: 0
                byline: 0
                portrait: 0
            p.on 'play', ->
                $player_el.addClass 'playback'

    io = new IntersectionObserver (entries, observer) ->
        for entry in entries
            $player_el = $(entry.target)
            vplayer = $player_el.prop 'vimeo-player'
            if entry.isIntersecting
                if vplayer
                    vplayer.play()
                else
                    vplayer = new Vimeo.Player $player_el.get(0),
                        id: $player_el.attr('data-vid')
                        background: 1
                        playsinline: 1
                        autopause: 0
                        title: 0
                        byline: 0
                        portrait: 0
                    $player_el.prop 'vimeo-player', vplayer
                    vplayer.on 'play', ->
                        $player_el.addClass 'playback'
            else
                vplayer?.pause()
    , threshold: 0.5
    $('.vimeo-video-box').each (idx, video_box) -> io.observe video_box

    $(document).on 'click', '[data-ym-reachgoal]', ->
        goal = $(this).attr('data-ym-reachgoal')
        ym?(553380, 'reachGoal', goal)
    $(document).on 'click', '.card-cell .buttonlike', -> ym?(553380, 'reachGoal', 'elite-bron')
