package org.kframework.krun.ioserver.commands;

import java.net.Socket;
import java.util.logging.Logger;

public class CommandUnknown extends Command {


	public CommandUnknown(String[] args, Socket socket, Logger logger) { //, Long maudeId) {
		super(args, socket, logger); //, maudeId);
		// TODO Auto-generated constructor stub
	}

	public void run() {
		fail("unknown command");
	}

}
