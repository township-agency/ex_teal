const wait = (delay = 100) => {
  return new Promise(resolve => {
    setTimeout(() => resolve(), delay);
  });
};

const minimum = (originalPromise, delay = 100) => {
  return Promise.all([
    originalPromise,
    wait(delay),
  ]).then(result => result[0]);
};

export default minimum;