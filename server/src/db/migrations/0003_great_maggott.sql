CREATE TABLE "channel_read_states" (
	"user_id" uuid NOT NULL,
	"channel_id" uuid NOT NULL,
	"last_read_message_id" text NOT NULL,
	CONSTRAINT "channel_read_states_user_id_channel_id_pk" PRIMARY KEY("user_id","channel_id")
);
--> statement-breakpoint
ALTER TABLE "channel_read_states" ADD CONSTRAINT "channel_read_states_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "channel_read_states" ADD CONSTRAINT "channel_read_states_channel_id_channels_id_fk" FOREIGN KEY ("channel_id") REFERENCES "public"."channels"("id") ON DELETE cascade ON UPDATE no action;