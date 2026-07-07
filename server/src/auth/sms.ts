export interface SmsSender {
  send(phone: string, body: string): Promise<void>;
}

export const devSms = (log: (msg: string) => void): SmsSender => ({
  async send(phone, body) {
    log(`[DEV SMS] to +${phone}: ${body}`);
  },
});

export function twilioSms(sid: string, token: string, from: string): SmsSender {
  return {
    async send(phone, body) {
      const res = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`, {
        method: 'POST',
        headers: {
          Authorization: 'Basic ' + Buffer.from(`${sid}:${token}`).toString('base64'),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({ To: `+${phone}`, From: from, Body: body }),
      });
      if (!res.ok) throw new Error(`Twilio ${res.status}: ${await res.text()}`);
    },
  };
}
