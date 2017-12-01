// execute inside the console of the input page

var arr =document.body.innerText.trim().split("");
var p = arr[arr.length-1];
var sum = 0;
arr.forEach((i) => { if ( i == p ) { sum+= parseInt(i,10) }; p = i  });
console.log(sum); //the output