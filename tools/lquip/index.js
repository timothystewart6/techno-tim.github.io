const lqip = require('lqip');
const fs = require('fs');
const path = require('path');

async function ls(dirPath) {
  const dir = await fs.promises.opendir(dirPath)
  for await (const file of dir) {
    const fullPath = `${dirPath}/${file.name}`;
    if (file.isDirectory()) {
      await ls(fullPath);
    } else if (file.name.toLowerCase().endsWith('.jpg')) {
      lqip.base64(fullPath).then(res => {
        console.log(' ')
        console.log(fullPath)
        console.log(' ')
        console.log(res); // "data:image/jpeg;base64,/9j/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhY.....
      });
    }
  }
}

ls('assets/img/headers').catch(console.error)
ls('assets/img/posts').catch(console.error)


