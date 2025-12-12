// I just ran this in the console of the input data in a browser window

const data = document.body.innerText.trim().split("\n\n");
const rows = data[data.length-1].split("\n");
const parsed_rows = rows.map((row) => { const [h, items] = row.split(": "); const [w,he] = h.split("x").map(Number); return [[w,he],items.split(" ").map(Number)]; });
const adiff = parsed_rows.map((row) => { const [wh, items] = row; const area = wh[0]*wh[1]; const sizes = [5,7,7,7,7,6]; const p_area = items.reduce((acc, item, i) => acc + item*sizes[i], 0); return area - p_area; });
console.log(adiff.filter((a) => a >= 0).length); //this is the answer
