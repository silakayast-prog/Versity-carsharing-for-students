import React, { useState } from 'react';
import { View, Text, StyleSheet, Alert } from 'react-native';
import { apiClient } from '../../api/client';
import { Input } from '../../components/Input';
import { Button } from '../../components/Button';
import { Card } from '../../components/Card';
import { colors, spacing, fontSizes, borderRadius } from '../../theme/theme';

export const QrScannerScreen = ({ navigation, route }: any) => {
  const [qrToken, setQrToken] = useState('');
  const [loading, setLoading] = useState(false);
  const rideId = route.params?.rideId || 'sample-ride-id';

  const handleVerify = async () => {
    if (!qrToken) {
      Alert.alert('Eksik Kod', 'Lütfen yolcunun ekranındaki QR kod içeriğini girin veya okutun.');
      return;
    }

    setLoading(true);
    try {
      const res: any = await apiClient.post(`/rides/${rideId}/verify-qr`, {
        qr_token: qrToken,
      });

      Alert.alert(
        '🎉 Biniş Başarıyla Onaylandı!',
        `Hesabınıza +${res.data?.kazanilan_puan || 10} Şoför Puanı eklendi.`,
        [{ text: 'Harika', onPress: () => navigation.goBack() }]
      );
    } catch (error: any) {
      Alert.alert('QR Doğrulama Hatalı', error.message || 'QR kod geçersiz veya süresi dolmuş.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Card style={styles.scannerBox}>
        <Text style={styles.cameraIcon}>📷</Text>
        <Text style={styles.title}>Yolcu QR Kod Tara</Text>
        <Text style={styles.subtitle}>
          Yolcunun telefon ekranında gösterdiği 15 dakika geçerli QR kodunu tarayın veya kodu aşağıya yapıştırın.
        </Text>

        <Input
          label="QR Token İçeriği"
          placeholder="yolculuk_id:yolcu_id:zaman:imza"
          value={qrToken}
          onChangeText={setQrToken}
          autoCapitalize="none"
        />

        <Button
          title="Binişi Doğrula & Puan Kazan"
          onPress={handleVerify}
          loading={loading}
          style={{ marginTop: spacing.md }}
        />

        <Button
          title="Vazgeç"
          variant="outline"
          onPress={() => navigation.goBack()}
          style={{ marginTop: spacing.sm }}
        />
      </Card>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    justifyContent: 'center',
    padding: spacing.lg,
  },
  scannerBox: {
    alignItems: 'center',
    padding: spacing.xl,
  },
  cameraIcon: {
    fontSize: 54,
    marginBottom: spacing.md,
  },
  title: {
    color: colors.text,
    fontSize: fontSizes.xl,
    fontWeight: '800',
    marginBottom: spacing.xs,
  },
  subtitle: {
    color: colors.textMuted,
    fontSize: fontSizes.xs,
    textAlign: 'center',
    marginBottom: spacing.lg,
  },
});
