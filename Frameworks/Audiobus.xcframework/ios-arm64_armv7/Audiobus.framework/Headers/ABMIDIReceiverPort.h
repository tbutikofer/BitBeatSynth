//
//  ABMIDIReceiverPort.h
//  Audiobus SDK
//
//  Created by Gabriel Gatzsche on 21.01.16.
//  Copyright © 2016 Audiobus Pty. Ltd. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif
    
#ifndef __ABMIDIReceiverPort_h

#import <Audiobus/ABMIDIPort.h>

@class ABMIDIReceiverPort;

/*!
 * Block to handle incoming MIDI messages
 *
 *  Note: this will be called on the realtime MIDI receive thread,
 *  so be careful not to do anything that could cause priority inversion,
 *  like calling Objective-C, allocating memory, or holding locks.
 *
 * @param source The source port
 * @param packetList The MIDI packets
 */
typedef void (^ABMIDIReceiverPortMIDIReceiverBlock)(__unsafe_unretained ABPort * _Nonnull source,
                                                    const MIDIPacketList * _Nonnull packetList);

/*!
 * Block to handle MIDI flush events
 *
 *  See ABMIDIReceiverPort's [MIDIFlushEventBlock](ABMIDIReceiverPort::MIDIFlushEventBlock) documentation
 *  for details.
 *
 *  Note: this will be called on the realtime MIDI receive thread,
 *  so be careful not to do anything that could cause priority inversion,
 *  like calling Objective-C, allocating memory, or holding locks.
 *
 * @param source The source port
 */
typedef void (^ABMIDIReceiverPortMIDIFlushEventBlock)(__unsafe_unretained ABPort * _Nonnull source);

/*!
 * Block to handle instance connection or disconnection
 *
 *  Use this with the multi-instance port initializer. It will be called on the main thread.
 *  You may assign a new MIDIReceiverBlock value for the new instance when this block is called,
 *  and it will replace the one you provided to the ABMIDIReceiverPort initializer.
 *
 * @param instance The instance
 */
typedef void (^ABMIDIReceiverPortInstanceConnectionBlock)(ABMIDIReceiverPort * _Nonnull instance);

/*!
 * ABMIDIReceiverPort receives MIDI messages.
 * 
 * The main things of ABMIDIReceiverPort is implemented in its base class
 * ABMIDIPort. So look into the documentation of this class.
 */
@interface ABMIDIReceiverPort : ABMIDIPort

/*!
 * Initialize
 *
 * Initializes a new MIDI Receiver Port.
 *
 * @param name Name of port, for internal use
 * @param title Title of port, shown to the user
 * @param receiverBlock The block for receiving incoming MIDI
 */
- (instancetype _Nullable)initWithName:(NSString * _Nonnull)name
                                 title:(NSString * _Nonnull)title
                         receiverBlock:(ABMIDIReceiverPortMIDIReceiverBlock _Nonnull)receiverBlock;

/*!
 * Initializes the MIDI Port as an multi instance port.
 *
 * Initializes a new MIDI Port. Use @link ABMIDIPortSendPacketList @endlink
 * to send MIDI data.
 *
 * @param name Name of port, for internal use
 * @param title Title of port, shown to the user
 * @param instanceConnectedBlock This block is called when a port instance has been connected.
 * @param instanceDisconnectedBlock This block is called when a port instance has been disconnected.
 */
- (instancetype _Nullable)initWithName:(NSString * _Nonnull)name
                                 title:(NSString * _Nonnull)title
                instanceConnectedBlock:(ABMIDIReceiverPortInstanceConnectionBlock _Nonnull)instanceConnectedBlock
             instanceDisconnectedBlock:(ABMIDIReceiverPortInstanceConnectionBlock _Nonnull)instanceDisconnectedBlock;

/*!
 * Currently-connected sources
 *
 *  This is an array of ABPort.
 */
@property (nonatomic, strong, readonly) NSArray * _Nonnull sources;

/*!
 * The block which is called when MIDI is received for the port.
 *
 *  Note: this will be called on the realtime MIDI receive thread,
 *  so be careful not to do anything that could cause priority inversion,
 *  like calling Objective-C, allocating memory, or holding locks.
 */
@property (nonatomic, copy) ABMIDIReceiverPortMIDIReceiverBlock _Nullable MIDIReceiverBlock;

/*!
 * The block which is called when a MIDI flush event occurs
 *
 *  Some MIDI sources may choose to send MIDI events some time in advance, in order
 *  to reduce latency or jitter effects. When this occurs, receivers will see incoming
 *  MIDI events with timestamps in the future, and should take steps to schedule the
 *  MIDI events accordingly.
 *
 *  To facilite elegant transport stop, MIDI sources will initiate a flush (see ABMIDIPortFlushOutput),
 *  which you should handle by assigning a block to this property. The block will be called
 *  when a flush occurs, and you should respond by unscheduling any pending events, and
 *  stopping any playing notes.
 *
 *  Note: this will be called on the realtime MIDI receive thread,
 *  so be careful not to do anything that could cause priority inversion,
 *  like calling Objective-C, allocating memory, or holding locks.
 */
@property (nonatomic, copy) ABMIDIReceiverPortMIDIFlushEventBlock _Nullable MIDIFlushEventBlock;

/*!
 * A title representing the sources connected to the port.
 */
@property (nonatomic, readonly) NSString * _Nullable sourcesTitle;

/*!
 * An icon representing the sources connected to the port.
 */
@property (nonatomic, readonly) UIImage * _Nullable sourcesIcon;


@end

#define __ABMIDIReceiverPort_h
#endif
    
#ifdef __cplusplus
}
#endif
