<?php

$url = 'https://www.opindia.com/category/politics/';

// 1st page to start scraping
$start_page = 1;

// number of pages.
// decrease it later for fast results
$max_pages = 5;

$sql_file = 'opindia-POL-'.date('Y-m-d__H:i:s__P_T').'.sql';
$sql_table = 'WEB_SCRAPE_RAW';

// extra scrape info to be added.
// needed to be customized as the url is changed
$scrape_info = array(
    "SCRAPE_SOURCE"=> 'OPINDIA/POL',
    "SCRAPE_TOPIC" => 'POLITICS',

    "COUNTRY_CODE" => 'IND',
    "SCRAPE_TAG1" => 'POLITICS',
    "SCRAPE_TAG2" => 'POLITICS',
    "SCRAPE_TAG3" => 'POLITICS',
);

// no. of times to retry a url
$max_retry = 5;

// full path to store file.
// if no path, current directory is used.
//
// $path = '/home/username/scrape/';
// $path = '/var/www/html/scraper/USAALL/';
$path = '/var/www/html/scraper/INDALL/';

// seconds for delay before calling next page.
// It might be necessary when calling 100+ pages
$page_delay = 1;

// seconds before repeating the same failure call
$retry_delay = 0;

// show data before creating sql
$show_array = true;

// =========================================


require '../phpQuery/phpQuery.php';

function get_current_scrape_info($scrape_info){

    $current_scrape_info = array(
        "SCRAPE_DATE"  => date('Y-m-d'),
        "SCRAPE_TIME"  => date('Y-m-d H:i:s')
    );

    $current_scrape_info = array_merge($current_scrape_info,$scrape_info);

    return $current_scrape_info;
}

function output_sql_file($sql_table,$sql_file,$articles,$current_scrape_info){

    $repeated = false;

    $sql = PHP_EOL.PHP_EOL;
    $sql .= 'INSERT INTO `'.$sql_table.'` (
                SCRAPE_DATE,
                SCRAPE_TIME,
                SCRAPE_SOURCE,
                SCRAPE_TOPIC,

                COUNTRY_CODE,
                SCRAPE_TAG1,
                SCRAPE_TAG2,
                SCRAPE_TAG3,

                NEWS_URL,
                NEWS_DTM_RAW,
                NEWS_DATE,
                NEWS_AUTHOR,
                NEWS_HEADLINE,

                NEWS_EXCERPT,
                NEWS_PIC_URL
            )
            VALUES '.PHP_EOL;

    foreach($articles as $article){

        $sql .= $repeated?',':'';

        $sql .= '('.
                    '"'.$current_scrape_info['SCRAPE_DATE'].'",'.
                    '"'.$current_scrape_info['SCRAPE_TIME'].'",'.
                    '"'.$current_scrape_info['SCRAPE_SOURCE'].'",'.
                    '"'.$current_scrape_info['SCRAPE_TOPIC'].'",'.

                    '"'.$current_scrape_info['COUNTRY_CODE'].'",'.
                    '"'.$current_scrape_info['SCRAPE_TAG1'].'",'.
                    '"'.$current_scrape_info['SCRAPE_TAG2'].'",'.
                    '"'.$current_scrape_info['SCRAPE_TAG3'].'",'.

                    '"'.$article['NEWS_URL'].'",'.
                    '"'.$article['NEWS_DTM_RAW'].'",'.
                    '"'.$article['NEWS_DATE'].'",'.
                    '"'.$article['NEWS_AUTHOR'].'",'.
                    '"'.$article['NEWS_HEADLINE'].'",'.

                    '"'.$article['NEWS_EXCERPT'].'",'.
                    '"'.$article['NEWS_PIC_URL'].'"'.
                ')';

        $sql .= PHP_EOL;

        $repeated = true;
    }
    $sql .= ';';

    file_put_contents($sql_file,$sql, FILE_APPEND );
}

function process_characters($text,$more=true,$numchars=null,$type='UTF-8'){

    $text = trim($text);

    $text = strip_tags($text);

    $text = html_entity_decode($text, ENT_QUOTES, $type);

    $text = str_replace('"','“',$text);

    $text = str_replace(array("\r", "\n"), ' , ', $text);

    $text = mb_substr($text, 0, $numchars, $type);

    if($more){
        $text .= "...";
    }

    return $text;
}

function process_excerprt($text){
    return process_characters($text);
    // return '';
}

function process_tags(){
    return '';
}

function process_author($text){
    return process_characters($text,false);
}

function process_headline($text){
    return trim(str_replace('"','\"',$text));
}

function process_datetime($NEWS_DTM_RAW){

    $d = new DateTime($NEWS_DTM_RAW);
    $datetime = $d->format('Y-m-d\TH:i:s');

    return array(
        $datetime,
        $datetime,
    );
}

// customized, same as dailypioneer
function process_date($text){

    $tmp = explode(' | ', $text);

    $tmp = trim($tmp[0]);

    return date("Y-m-d\TH:i:s",strtotime($tmp));
}

function process_href($cur_href, $base_url){

    // no or empty href
    if( ($cur_href=='') || ($cur_href=='#') ) {
        return false;
    }

    // a anchor
    if( (substr($cur_href,0,1)=='#') && (strlen($cur_href)>1) ) {
        return $base_url.$cur_href;
    }
    // base url
    if(substr($cur_href,0,1)=='/'){
        return $base_url.$cur_href;
    }

    return $cur_href;
}

function process_opindia_each($item,$max_retry,$retry_delay){

    $NEWS_URL = '';
    $NEWS_DTM_RAW = '';
    $NEWS_DATE = '';
    $NEWS_AUTHOR = '';
    $NEWS_HEADLINE = '';



    $NEWS_URL = process_headline($item->find('h3')->eq(0)->find('a')->eq(0)->attr('href'));

    $NEWS_HEADLINE = process_headline($item->find('h3')->eq(0)->find('a')->eq(0)->text());

    $NEWS_DTM_RAW = process_date($item->find('time')->attr('datetime'));

    list($NEWS_DTM_RAW,$NEWS_DATE) = process_datetime($NEWS_DTM_RAW);

    $NEWS_EXCERPT = process_excerprt($item->find('div.td-excerpt')->eq(0)->text());

    $NEWS_AUTHOR = process_author(
        $item->find('span.td-post-author-name')->eq(0)->children('a')->eq(0)->text()
    );

    $NEWS_PIC_URL = $item->find('span.entry-thumb.td-thumb-css')->attr('data-img-url');

    $result = compact(
        'NEWS_URL',
        'NEWS_DTM_RAW',
        'NEWS_DATE',
        'NEWS_AUTHOR',
        'NEWS_HEADLINE',
        'NEWS_EXCERPT',
        'NEWS_PIC_URL'
    );


    return $result;
}

function get_url($url,$max_retry,$retry_delay){

    $retry = 0;

    do{
        $string = @file_get_contents($url);
        if($string===false){

            sleep($retry_delay);
            echo PHP_EOL.'sleeping for '.$url.PHP_EOL;

            if($retry>=$max_retry){
                echo $max_retry.' unsuccessful retried to '.$url.PHP_EOL;
                echo 'Abrubt Ending.';
                die;
            }
        }
        $retry++;
    }while($string===false);

    return $string;
}

function get_next_page_url($string,$url){
    return pq('.page-nav .td-icon-menu-right')->parent()->attr('href');
}

function scrape(
    $sql_table,
    $url,
    $sql_file,

    $current_page,
    $max_pages,

    $retry_delay,
    $max_retry,
    $page_delay,

    $show_array,
    $scrape_info

){
    // maximum number of pages
    if($current_page>$max_pages) {
        return;
    }

    $articles = [];

    $string = get_url($url,$max_retry,$retry_delay);

    $string = phpQuery::newDocument($string);


    $next_page_url = get_next_page_url($string,$url);


    // ------------------------------
    // each page

        $posts = pq('div.tdb_module_loop.td_module_wrap.td-animation-stack');
        $count = count($posts);

        for($i=0;$i<$count;$i++){

            $article = [];

            $article = process_opindia_each($posts->eq($i),$max_retry,$retry_delay);
            // print_r($article);
            // die;

            if( $article==false ) {
                continue;
            }

            $articles[] = $article;
        }
    // ------------------------------
    // print_r($articles);
    // die;


    $current_scrape_info = get_current_scrape_info($scrape_info);

    if($show_array){
        print_r($url);
        echo PHP_EOL;
        print_r ($current_scrape_info);
        print_r ($articles);
        echo PHP_EOL.PHP_EOL.PHP_EOL.PHP_EOL;
    }

    output_sql_file($sql_table,$sql_file,$articles,$current_scrape_info);


    // ------------------------------
    // move on to next page if exist

        if($next_page_url){

            sleep($page_delay);

            scrape(
                $sql_table,
                $next_page_url,
                $sql_file,

                ($current_page+1),
                $max_pages,

                $retry_delay,
                $max_retry,
                $page_delay,

                $show_array,
                $scrape_info
            );
        }
    // ------------------------------

}


// =========================================


scrape(
    $sql_table,
    $url,
    $path.$sql_file,

    $start_page,
    $max_pages,

    $retry_delay,
    $max_retry,
    $page_delay,

    $show_array,
    $scrape_info
);
