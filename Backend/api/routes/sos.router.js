app.post("/api/send-sms", async (req, res) => {
  const { phone, message } = req.body;

  try {
    const response = await axios.post("https://www.fast2sms.com/dev/bulkV2", null, {
      params: {
        authorization: "w2mzrcv6DjM5LyC0Zig7W9kSbtKYo4xUGPdJTOBVesnufpIhFH9ZIlRt2Sjs4xK05VmAo6cHTrkLGaPU",
        message: message,
        language: "english",
        route: "q",
        numbers: phone,
      },
    });

    if (response.data.return === true) {
      res.status(200).json({ success: true, message: "SMS sent successfully" });
    } else {
      res.status(500).json({ success: false, message: "SMS sending failed" });
    }
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});
