export interface SmsSender {
  send(phone: string, body: string): Promise<void>;
}
