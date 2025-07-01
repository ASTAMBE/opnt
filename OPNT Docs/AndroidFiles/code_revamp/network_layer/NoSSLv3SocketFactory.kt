package com.opinito.social.code_revamp.network_layer

import info.guardianproject.netcipher.NetCipher
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.net.InetAddress
import java.net.Socket
import java.net.SocketAddress
import java.net.SocketException
import java.net.URL
import java.nio.channels.SocketChannel
import java.util.Arrays
import javax.net.ssl.HandshakeCompletedListener
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLSession
import javax.net.ssl.SSLSocket
import javax.net.ssl.SSLSocketFactory


class NoSSLv3SocketFactory : SSLSocketFactory {
    private val delegate: SSLSocketFactory



    constructor(sourceUrl: URL?) {
        delegate = NetCipher.getHttpsURLConnection(sourceUrl).sslSocketFactory
    }

    constructor() {
        delegate = HttpsURLConnection.getDefaultSSLSocketFactory()
    }

    constructor(delegate: SSLSocketFactory) {
        this.delegate = delegate
    }



    private fun makeSocketSafe(socket: Socket): Socket {
        var socket = socket
        if (socket is SSLSocket) {
            socket = NoSSLv3SSLSocket(socket)
        }
        return socket
    }

    @Throws(IOException::class)
    override fun createSocket(s: Socket?, host: String?, port: Int, autoClose: Boolean): Socket {
        return makeSocketSafe(delegate.createSocket(s, host, port, autoClose))
    }

    @Throws(IOException::class)
    override fun createSocket(host: String?, port: Int): Socket {
        return makeSocketSafe(delegate.createSocket(host, port))
    }

    @Throws(IOException::class)
    override fun createSocket(host: String?, port: Int, localHost: InetAddress?, localPort: Int): Socket {
        return makeSocketSafe(delegate.createSocket(host, port, localHost, localPort))
    }

    @Throws(IOException::class)
    override fun createSocket(host: InetAddress?, port: Int): Socket {
        return makeSocketSafe(delegate.createSocket(host, port))
    }

    @Throws(IOException::class)
    override fun createSocket(
        address: InetAddress?,
        port: Int,
        localAddress: InetAddress?,
        localPort: Int
    ): Socket {
        return makeSocketSafe(delegate.createSocket(address, port, localAddress, localPort))
    }

    override fun getDefaultCipherSuites(): Array<String> {
        return delegate.getDefaultCipherSuites()
    }

    override fun getSupportedCipherSuites(): Array<String> {
        return delegate.getSupportedCipherSuites()
    }

    private inner class NoSSLv3SSLSocket(delegate: SSLSocket) :
        DelegateSSLSocket(delegate) {
        override fun setEnabledProtocols(protocols: Array<String>) {
            var protocols = protocols
            if (protocols != null && protocols.size == 1 && "SSLv3" == protocols[0]) {
                val enabledProtocols: MutableList<String> =
                    ArrayList(Arrays.asList(*delegate.getEnabledProtocols()))
                if (enabledProtocols.size > 1) {
                    enabledProtocols.remove("SSLv3")
                    println("Removed SSLv3 from enabled protocols")
                } else {
                    println("SSL stuck with protocol available for $enabledProtocols")
                }
                protocols = enabledProtocols.toTypedArray<String>()
            }
            super.setEnabledProtocols(protocols)
        }
    }

    open inner class DelegateSSLSocket internal constructor(protected val delegate: SSLSocket) :
        SSLSocket() {
        override fun getSupportedCipherSuites(): Array<String> {
            return delegate.supportedCipherSuites
        }

        override fun getEnabledCipherSuites(): Array<String> {
            return delegate.enabledCipherSuites
        }

        override fun setEnabledCipherSuites(suites: Array<String>) {
            delegate.enabledCipherSuites = suites
        }

        override fun getSupportedProtocols(): Array<String> {
            return delegate.supportedProtocols
        }

        override fun getEnabledProtocols(): Array<String> {
            return delegate.enabledProtocols
        }

        override fun setEnabledProtocols(protocols: Array<String>) {
            delegate.enabledProtocols = protocols
        }

        override fun getSession(): SSLSession {
            return delegate.session
        }

        override fun addHandshakeCompletedListener(listener: HandshakeCompletedListener) {
            delegate.addHandshakeCompletedListener(listener)
        }

        override fun removeHandshakeCompletedListener(listener: HandshakeCompletedListener) {
            delegate.removeHandshakeCompletedListener(listener)
        }

        @Throws(IOException::class)
        override fun startHandshake() {
            delegate.startHandshake()
        }

        override fun setUseClientMode(mode: Boolean) {
            delegate.useClientMode = mode
        }

        override fun getUseClientMode(): Boolean {
            return delegate.useClientMode
        }

        override fun setNeedClientAuth(need: Boolean) {
            delegate.needClientAuth = need
        }

        override fun setWantClientAuth(want: Boolean) {
            delegate.wantClientAuth = want
        }

        override fun getNeedClientAuth(): Boolean {
            return delegate.needClientAuth
        }

        override fun getWantClientAuth(): Boolean {
            return delegate.wantClientAuth
        }

        override fun setEnableSessionCreation(flag: Boolean) {
            delegate.enableSessionCreation = flag
        }

        override fun getEnableSessionCreation(): Boolean {
            return delegate.enableSessionCreation
        }

        @Throws(IOException::class)
        override fun bind(localAddr: SocketAddress) {
            delegate.bind(localAddr)
        }

        @Synchronized
        @Throws(IOException::class)
        override fun close() {
            delegate.close()
        }

        @Throws(IOException::class)
        override fun connect(remoteAddr: SocketAddress) {
            delegate.connect(remoteAddr)
        }

        @Throws(IOException::class)
        override fun connect(remoteAddr: SocketAddress, timeout: Int) {
            delegate.connect(remoteAddr, timeout)
        }

        override fun getChannel(): SocketChannel {
            return delegate.channel
        }

        override fun getInetAddress(): InetAddress {
            return delegate.getInetAddress()
        }

        @Throws(IOException::class)
        override fun getInputStream(): InputStream {
            return delegate.getInputStream()
        }

        @Throws(SocketException::class)
        override fun getKeepAlive(): Boolean {
            return delegate.getKeepAlive()
        }

        override fun getLocalAddress(): InetAddress {
            return delegate.getLocalAddress()
        }

        override fun getLocalPort(): Int {
            return delegate.getLocalPort()
        }

        override fun getLocalSocketAddress(): SocketAddress {
            return delegate.getLocalSocketAddress()
        }

        @Throws(SocketException::class)
        override fun getOOBInline(): Boolean {
            return delegate.getOOBInline()
        }

        @Throws(IOException::class)
        override fun getOutputStream(): OutputStream {
            return delegate.getOutputStream()
        }

        override fun getPort(): Int {
            return delegate.getPort()
        }

        @Synchronized
        @Throws(SocketException::class)
        override fun getReceiveBufferSize(): Int {
            return delegate.getReceiveBufferSize()
        }

        override fun getRemoteSocketAddress(): SocketAddress {
            return delegate.getRemoteSocketAddress()
        }

        @Throws(SocketException::class)
        override fun getReuseAddress(): Boolean {
            return delegate.getReuseAddress()
        }

        @Synchronized
        @Throws(SocketException::class)
        override fun getSendBufferSize(): Int {
            return delegate.getSendBufferSize()
        }

        @Throws(SocketException::class)
        override fun getSoLinger(): Int {
            return delegate.getSoLinger()
        }

        @Synchronized
        @Throws(SocketException::class)
        override fun getSoTimeout(): Int {
            return delegate.getSoTimeout()
        }

        @Throws(SocketException::class)
        override fun getTcpNoDelay(): Boolean {
            return delegate.getTcpNoDelay()
        }

        @Throws(SocketException::class)
        override fun getTrafficClass(): Int {
            return delegate.getTrafficClass()
        }

        override fun isBound(): Boolean {
            return delegate.isBound
        }

        override fun isClosed(): Boolean {
            return delegate.isClosed
        }

        override fun isConnected(): Boolean {
            return delegate.isConnected
        }

        override fun isInputShutdown(): Boolean {
            return delegate.isInputShutdown
        }

        override fun isOutputShutdown(): Boolean {
            return delegate.isOutputShutdown
        }

        @Throws(IOException::class)
        override fun sendUrgentData(value: Int) {
            delegate.sendUrgentData(value)
        }

        @Throws(SocketException::class)
        override fun setKeepAlive(keepAlive: Boolean) {
            delegate.setKeepAlive(keepAlive)
        }

        @Throws(SocketException::class)
        override fun setOOBInline(oobinline: Boolean) {
            delegate.setOOBInline(oobinline)
        }

        override fun setPerformancePreferences(connectionTime: Int, latency: Int, bandwidth: Int) {
            delegate.setPerformancePreferences(connectionTime, latency, bandwidth)
        }

        @Synchronized
        @Throws(SocketException::class)
        override fun setReceiveBufferSize(size: Int) {
            delegate.setReceiveBufferSize(size)
        }

        @Throws(SocketException::class)
        override fun setReuseAddress(reuse: Boolean) {
            delegate.setReuseAddress(reuse)
        }

        @Synchronized
        @Throws(SocketException::class)
        override fun setSendBufferSize(size: Int) {
            delegate.setSendBufferSize(size)
        }

        @Throws(SocketException::class)
        override fun setSoLinger(on: Boolean, timeout: Int) {
            delegate.setSoLinger(on, timeout)
        }

        @Synchronized
        @Throws(SocketException::class)
        override fun setSoTimeout(timeout: Int) {
            delegate.setSoTimeout(timeout)
        }

        @Throws(SocketException::class)
        override fun setTcpNoDelay(on: Boolean) {
            delegate.setTcpNoDelay(on)
        }

        @Throws(SocketException::class)
        override fun setTrafficClass(value: Int) {
            delegate.setTrafficClass(value)
        }

        @Throws(IOException::class)
        override fun shutdownInput() {
            delegate.shutdownInput()
        }

        @Throws(IOException::class)
        override fun shutdownOutput() {
            delegate.shutdownOutput()
        }

        override fun toString(): String {
            return delegate.toString()
        }

        override fun equals(o: Any?): Boolean {
            return delegate == o
        }
    }
}