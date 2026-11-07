import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Alert, ScrollView } from 'react-native';
import { useAuth } from '../../context/AuthContext';
import { Input } from '../../components/Input';
import { Button } from '../../components/Button';
import { colors, spacing, fontSizes, borderRadius } from '../../theme/theme';

export const RegisterScreen = ({ navigation }: any) => {
  const { register, isLoading } = useAuth();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [ageConsent, setAgeConsent] = useState(true);
  const [kvkkConsent, setKvkkConsent] = useState(true);

  const handleRegister = async () => {
    if (!fullName || !email || !password) {
      Alert.alert('Eksik Bilgi', 'Lütfen ad soyad, okul e-postası ve şifre alanlarını doldurun.');
      return;
    }

    if (!email.toLowerCase().endsWith('.edu.tr')) {
      Alert.alert('Güvenlik Uyarısı', 'Sadece ".edu.tr" uzantılı üniversite e-postaları kabul edilir.');
      return;
    }

    if (!ageConsent || !kvkkConsent) {
      Alert.alert('Onay Gerekli', 'Lütfen 18 yaş ve KVKK onay kutularını işaretleyin.');
      return;
    }

    try {
      await register({
        ad_soyad: fullName,
        okul_email: email,
        sifre: password,
        yas_onay: ageConsent,
        kvkk_onay: kvkkConsent,
      });
    } catch (error: any) {
      Alert.alert('Kayıt Hatalı', error.message || 'Kayıt gerçekleştirilemedi.');
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.card}>
        <Text style={styles.title}>Öğrenci Kaydı 🎓</Text>
        <Text style={styles.subtitle}>Sadece kapalı topluluk üyeleri içindir</Text>

        <Input
          label="Ad Soyad"
          placeholder="Örn: Ahmet Yılmaz"
          value={fullName}
          onChangeText={setFullName}
        />

        <Input
          label="Üniversite E-postası (.edu.tr)"
          placeholder="ogrenci@antalyabilim.edu.tr"
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
        />

        <Input
          label="Şifre Oluşturun (en az 6 karakter)"
          placeholder="••••••••"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
        />

        <TouchableOpacity
          style={styles.checkboxRow}
          onPress={() => setAgeConsent(!ageConsent)}
        >
          <View style={[styles.checkbox, ageConsent && styles.checkboxActive]}>
            {ageConsent && <Text style={styles.checkmark}>✓</Text>}
          </View>
          <Text style={styles.checkboxText}>En az 18 yaşında olduğumu beyan ederim.</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.checkboxRow}
          onPress={() => setKvkkConsent(!kvkkConsent)}
        >
          <View style={[styles.checkbox, kvkkConsent && styles.checkboxActive]}>
            {kvkkConsent && <Text style={styles.checkmark}>✓</Text>}
          </View>
          <Text style={styles.checkboxText}>KVKK Aydınlatma Metnini okudum ve kabul ediyorum.</Text>
        </TouchableOpacity>

        <Button
          title="Kaydol ve Doğrula"
          onPress={handleRegister}
          loading={isLoading}
          style={{ marginTop: spacing.lg }}
        />

        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.loginLink}>
          <Text style={styles.loginText}>
            Zaten hesabınız var mı? <Text style={{ color: colors.primary, fontWeight: '700' }}>Giriş Yapın</Text>
          </Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    backgroundColor: colors.background,
    justifyContent: 'center',
    padding: spacing.lg,
  },
  card: {
    backgroundColor: colors.cardGlass,
    borderRadius: borderRadius.lg,
    padding: spacing.xl,
    borderWidth: 1,
    borderColor: colors.border,
  },
  title: {
    fontSize: fontSizes.xl,
    fontWeight: '800',
    color: colors.text,
  },
  subtitle: {
    fontSize: fontSizes.sm,
    color: colors.textMuted,
    marginBottom: spacing.lg,
  },
  checkboxRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  checkbox: {
    width: 20,
    height: 20,
    borderRadius: 4,
    borderWidth: 1,
    borderColor: colors.border,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.sm,
    backgroundColor: colors.surfaceLight,
  },
  checkboxActive: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  checkmark: {
    color: '#FFF',
    fontWeight: 'bold',
    fontSize: 12,
  },
  checkboxText: {
    color: colors.textSecondary,
    fontSize: fontSizes.xs,
    flex: 1,
  },
  loginLink: {
    alignItems: 'center',
    marginTop: spacing.lg,
  },
  loginText: {
    color: colors.textSecondary,
    fontSize: fontSizes.sm,
  },
});
