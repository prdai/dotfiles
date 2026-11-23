export interface EmailRecord {
  id: string;
  receivedAt: number;
  from: string;
  to: string;
  subject: string;
  text: string;
  html: string;
  messageId: string;
  otp: string;
  truncated: number;
}

export interface EmailSummary {
  id: string;
  receivedAt: number;
  from: string;
  to: string;
  subject: string;
  truncated: boolean;
}

export interface EmailFilters {
  to?: string;
  from?: string;
  subject?: string;
  since?: number;
  q?: string;
  limit: number;
}

export interface EmailRow {
  id: string;
  received_at: number;
  from_addr: string;
  to_addr: string;
  subject: string;
  text_body: string;
  html_body: string;
  message_id: string;
  otp: string;
  truncated: number;
}
