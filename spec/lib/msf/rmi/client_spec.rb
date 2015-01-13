# -*- coding:binary -*-
require 'spec_helper'

require 'rex/java/serialization'
require 'rex/proto/rmi'
require 'msf/rmi/client'

class RmiStringIO < StringIO

  def put(data)
    write(data)
  end

  def get_once(length = -1, timeout = 10)
    read
  end
end

describe Msf::Rmi::Client do
  subject(:mod) do
    mod = ::Msf::Exploit.new
    mod.extend ::Msf::Rmi::Client
    mod.send(:initialize)
    mod
  end

  let(:io) { RmiStringIO.new('', 'w+b') }
  let(:protocol_not_supported) { "\x4f" }
  let(:protocol_not_supported_io) { RmiStringIO.new(protocol_not_supported) }
  let(:protocol_ack) { "\x4e\x00\x0e\x31\x37\x32\x2e\x31\x36\x2e\x31\x35\x38\x2e\x31\x33\x32\x00\x00\x06\xea" }
  let(:protocol_ack_io) { RmiStringIO.new(protocol_ack) }
  let(:return_data) do
    "\x51\xac\xed\x00\x05\x77\x0f\x01\xd2\x4f\xdf\x47\x00\x00\x01\x49" +
    "\xb5\xe4\x92\x78\x80\x15\x73\x72\x00\x12\x6a\x61\x76\x61\x2e\x72" +
    "\x6d\x69\x2e\x64\x67\x63\x2e\x4c\x65\x61\x73\x65\xb0\xb5\xe2\x66" +
    "\x0c\x4a\xdc\x34\x02\x00\x02\x4a\x00\x05\x76\x61\x6c\x75\x65\x4c" +
    "\x00\x04\x76\x6d\x69\x64\x74\x00\x13\x4c\x6a\x61\x76\x61\x2f\x72" +
    "\x6d\x69\x2f\x64\x67\x63\x2f\x56\x4d\x49\x44\x3b\x70\x78\x70\x00" +
    "\x00\x00\x00\x00\x09\x27\xc0\x73\x72\x00\x11\x6a\x61\x76\x61\x2e" +
    "\x72\x6d\x69\x2e\x64\x67\x63\x2e\x56\x4d\x49\x44\xf8\x86\x5b\xaf" +
    "\xa4\xa5\x6d\xb6\x02\x00\x02\x5b\x00\x04\x61\x64\x64\x72\x74\x00" +
    "\x02\x5b\x42\x4c\x00\x03\x75\x69\x64\x74\x00\x15\x4c\x6a\x61\x76" +
    "\x61\x2f\x72\x6d\x69\x2f\x73\x65\x72\x76\x65\x72\x2f\x55\x49\x44" +
    "\x3b\x70\x78\x70\x75\x72\x00\x02\x5b\x42\xac\xf3\x17\xf8\x06\x08" +
    "\x54\xe0\x02\x00\x00\x70\x78\x70\x00\x00\x00\x08\x6b\x02\xc7\x72" +
    "\x60\x1c\xc7\x95\x73\x72\x00\x13\x6a\x61\x76\x61\x2e\x72\x6d\x69" +
    "\x2e\x73\x65\x72\x76\x65\x72\x2e\x55\x49\x44\x0f\x12\x70\x0d\xbf" +
    "\x36\x4f\x12\x02\x00\x03\x53\x00\x05\x63\x6f\x75\x6e\x74\x4a\x00" +
    "\x04\x74\x69\x6d\x65\x49\x00\x06\x75\x6e\x69\x71\x75\x65\x70\x78" +
    "\x70\x80\x01\x00\x00\x01\x49\xb5\xf8\x00\xea\xe9\x62\xc1\xc0"
  end
  let(:return_io) { RmiStringIO.new(return_data) }

  describe "#send_header" do
    it "returns the number of bytes sent" do
      expect(mod.send_header(sock: io)).to eq(13)
    end
  end

  describe "#send_call" do
    it "returns the number of bytes sent" do
      expect(mod.send_call(sock: io)).to eq(5)
    end
  end

  describe "#send_dgc_ack" do
    it "returns the number of bytes sent" do
      expect(mod.send_dgc_ack(sock: io)).to eq(15)
    end
  end

  describe "#recv_protocol_ack" do
    context "when end point returns protocol ack" do
      it "returns a Rex::Proto::Rmi::Model::ProtocolAck" do
        expect(mod.recv_protocol_ack(sock: protocol_ack_io)).to be_a(Rex::Proto::Rmi::Model::ProtocolAck)
      end
    end

    context "when end point returns protocol not supported" do
      it "return nil" do
        expect(mod.recv_protocol_ack(sock: protocol_not_supported_io)).to be_nil
      end
    end
  end

  describe "#recv_return" do
    context "when end point returns a value to the call" do
      it "returns a Rex::Java::Serialization::Model::Stream" do
        expect(mod.recv_return(sock: return_io)).to be_a(Rex::Java::Serialization::Model::Stream)
      end
    end

    context "when end point doesn't return a value to the call" do
      it "returns nil" do
        expect(mod.recv_return(sock: io)).to be_nil
      end
    end
  end
end

