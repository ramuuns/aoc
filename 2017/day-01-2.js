// execute inside the console of the input page

var arr =document.body.innerText.trim().split("");
var sum = 0;
var l = arr.length;
var offset = l / 2;
arr.forEach((i, idx) => { 
    if ( i == arr[(idx+offset)%l] ) { sum+= parseInt(i,10) } 
});
console.log(sum); //the output