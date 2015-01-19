# Description:
#   Traffic maps
#
# Commands:
#   hubot traffic <query>
#   hubot traffic dal|aus|hou

# To get an ID:
#  1. do a google search for "<x> traffic map"
#  2. Right click the "Current traffic for <x>" image and copy source
#  3. The ID is the data= portion after the comma
# TODO: could scrape the Google search page, but that is against TOS.

places =
  dal: "U4aSnIyhBFNIJ3A8fCzUmaVIwyWq6RtIfB4QKiGq_w,y5-fb0-9ikWnKrvyYZPXcifFeIPouFEBwV2vKYOEvriC8cTuwpyrBj8Jaiv2OjEeUdMhGpJ2E_5naP_9mDmUMD-18ZF-A9oiRJMoTtfMG2M8ABezdhoLe94Gwd7fEolvX1N4cOHDK6yW8991SMJTMBeUxiF4Qw898ED4"
  aus: "U4aSnIyhBFNIJ3A8fCzUmaVIwyWq6RtIfB4QKiGq_w,4lO57Gh90yIfMzaBMAX2wowNTLltKqOP7aO1Q0kpAjC_-fN_JrEnH6o2yORV3aPJMdrFwShN5b8T_8ne2uLFJruZGdHkM5ClezB0VXl_kLe4fSqCalgPY1A0qZnH-aH48sWMi1dDKjCv5MyUVqZ-2D3vrPLkEIDIJrNh"
  hou: "U4aSnIyhBFNIJ3A8fCzUmaVIwyWq6RtIfB4QKiGq_w,0EG6F1wXmNa4xd49RVPmrbxLbWg8aSmhe_-obmLywN5C2eyLn3-X2Q6xlkyHwC0KCQKPYZEOiylceCAc8QwZ900PYBKLQdkgviqIG9PB_eEBWUCp7SrPDKXQQqqhmAIWC0i4FkciEpPu6ZxJzj_2nq6GVvDXjEnjuzQO"

defaultPlace = "sf"


module.exports = (robot) ->
  robot.respond /traffic( me)?( (.*))?/i, (msg) ->
    id = places[msg.match[3] or defaultPlace]
    if id
      msg.send "https://www.google.com/maps/vt/data=#{id}##{Date.now()}.png"
    else
      msg.send "I only have traffic configured for: #{Object.keys(data).join(', ')}"