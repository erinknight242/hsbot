// Description:
//   Gets the list of the day's restaurants from Lunchdrop.com
//
// Commands:
//   hsbot lunchdrop - Returns the list of restaurants scheduled for the day.

module.exports = function lunchdropCommand(robot) {
  robot.respond(/lunchdrop/i, (res) => {
    // Unsupported public api endpoint to get a specific company's deliveries for the day
    const restaurantsUrl =
      'https://lunchdrop.com/todays-lunch/qanywdnb/e3d32a39326f2ddc9132ca95454ee42c?include=restaurant';
    const signUpLink = 'https://lunchdrop.com/join/BRAN0161';
    const orderLink = 'https://lunchdrop.com/app';

    robot.http(restaurantsUrl).get()((err, response, body) => {
      try {
        const todaysLunch = JSON.parse(body);
        if (!todaysLunch.deliveries || !todaysLunch.deliveries.length) {
          res.send('No restaurants currently scheduled for today.');
        }

        res.send("Today's restaurants from Lunchdrop are:");
        todaysLunch.deliveries.forEach(x => res.send(`\n${x.restaurant.name}`));
        res.send(`\nOrder: ${orderLink}`);
        res.send(`Sign up: ${signUpLink}`);
      } catch (e) {
        res.send("Sorry I wasn't able to understand what lunchdrop said.");
      }
    });
  });
};
