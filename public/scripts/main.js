
$(function() {
    $(".comment").hover(function() {
        $(this).children(".class").toggleClass("change");
    });
}); 

// sample funciton to have different Jake thumbnail
// on each new page

jakeImgArr = []



//  for (var i = 0; i < 10; i ++) {
// 	jakeImgArr.push ('./images/jake_' + i + '.jpg')
// }

pics = [
	'../images/jake_1.jpg',
	'../images/jake_2.jpg',
	'../images/jake_3.jpg',
	'../images/jake_4.jpg',
	'../images/jake_5.jpg',
	'../images/jake_6.jpg',
	'../images/jake_7.jpg',
	'../images/jake_8.jpg',
	'../images/jake_9.jpg',
	'../images/jake_10.jpg',
	'../images/jake_11.jpg',
	'../images/jake_12.jpg',
	'../images/jake_13.jpg',
	'../images/jake_14.jpg',
	'../images/jake_15.jpg',
	'../images/jake_16.jpg',
	'../images/jake_17.jpg',
	'../images/jake_18.jpg',
	'../images/jake_19.jpg',
	'../images/jake_20.jpg',
	'../images/jake_21.jpg'
]

var jakeImgArr = new Array();
// var pictures;


// function initialize(){
//   // sets up the array with some startin values
//   // Andy Harris
//   for (var i = 0; i < 8; i ++) {

// 	  var pictures + i.to_s = new Image(50, 50);
// 	  (pictures + i.to_s).src = '../images/jake_' + i + '.jpg'
// 		jakeImgArr.push(puctures[i])
// 	}
// } // end initialize 

function random_imglink(){
	var rand = Math.floor(Math.random() * pics.length)
	document.getElementById('random_jake').innerHTML = '<img src="'+ pics[rand] + '">';
}

function random_thumbnail(){
	var rand = Math.floor(Math.random() * pics.length);
	var image = document.getElementsByClassName('thumbnail');
	image.innerHTML = '<img src="'+ pics[rand] + '">';
}


// $(function() {
//   $("upvote_vote").click(function() {
//   ame as putting onclick="return false;" in HTML
//    return false;
//   })
// });


// initialize()
// window.onload = random_imglink;
// turn img links to display
$(window).load(function(){
	random_imglink();
	random_thumbnail();
	var allImgHref = $('.content').find('a').attr('href');
	var allImg = $('.content').find('a')[0]
	allImg.innerHTML = allImg.innerHTML + "<img src=\"" + allImgHref + "\">";
});

